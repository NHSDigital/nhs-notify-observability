const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");
const https = require('https');
const axios = require('axios');
const pino = require('pino');

const logger = pino();
const ssmClient = new SSMClient({ region: "eu-west-2" });

async function getTeamsWebhookUrl(parameterName) {
    logger.info({ msg: 'SSM Parameter Name', parameterName });
    if (!parameterName) {
        logger.error({ msg: 'No SSM parameter name found in environment variables' });
        return null;
    }
    try {
        const command = new GetParameterCommand({
            Name: parameterName,
            WithDecryption: true,
        });
        const response = await ssmClient.send(command);
        logger.debug({ msg: 'SSM Parameter Response', response });
        if (!response.Parameter) {
            logger.error({ msg: 'SSM Parameter not found' });
            return null;
        }
        return response.Parameter.Value || null;
    } catch (error) {
        logger.error({ msg: 'Error retrieving SSM Parameter', error, details: error.message, stack: error.stack });
        return null;
    }
}

function extractSecurityHubSections(message) {
    let cleaned = message.replace(/\\\\n/g, '\n').replace(/\\n/g, '\n');
    cleaned = cleaned.replace(/-+\n/g, '');
    const rawSections = cleaned.split(/\n{2,}/).map(s => s.trim()).filter(Boolean);
    return rawSections.map(section => {
        const lines = section.split('\n').filter(Boolean);
        if (lines.length < 2) return null;
        const header = `**${lines[0]}**<br>`;
        const findings = lines.slice(1)
            .map(line => line.trim())
            .filter(Boolean)
            .map(line => {
                const m = line.match(/^(\S+)\s+(\d+)$/);
                return m ? `${m[1].padEnd(30)}${m[2]}<br>` : line + '<br>';
            })
            .filter(Boolean)
            .sort((a, b) => a.localeCompare(b));
        return `${header}${findings.join('')}`;
    }).filter(Boolean).join('<br><br>');
}

async function sendTeamsMessage(teamsPayload, url, retries = 3) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: url.hostname,
            path: url.pathname,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(teamsPayload),
            },
            timeout: 5000,
        };

        logger.info({ msg: 'Request options', options });
        logger.debug({ msg: 'Payload', payload: teamsPayload });

        const req = https.request(options, (res) => {
            let data = '';

            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                console.log("Response status code:", res.statusCode);
                console.log("Response data:", data);
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    console.log("Message successfully sent to Microsoft Teams");
                    resolve();
                } else {
                    console.error(`Failed to send message to Teams: ${res.statusCode} ${res.statusMessage}`);
                    if (retries > 0) {
                        console.log(`Retrying... (${retries} retries left)`);
                        setTimeout(() => {
                            sendTeamsMessage(teamsPayload, url, retries - 1).then(resolve).catch(reject);
                        }, 5000);
                    } else {
                        reject(new Error(`Failed to send message to Teams after ${retries} retries`));
                    }
                }
            });
        });

        req.on('error', (error) => {
            console.error("Error sending message to Teams:", error);
            if (retries > 0) {
                console.log(`Retrying... (${retries} retries left)`);
                setTimeout(() => {
                    sendTeamsMessage(teamsPayload, url, retries - 1).then(resolve).catch(reject);
                }, 5000);
            } else {
                reject(new Error(`Failed to send message to Teams after ${retries} retries`));
            }
        });

        req.on('timeout', () => {
            req.abort();
            console.error("Request timed out");
            if (retries > 0) {
                console.log(`Retrying... (${retries} retries left)`);
                setTimeout(() => {
                    sendTeamsMessage(teamsPayload, url, retries - 1).then(resolve).catch(reject);
                }, 5000);
            } else {
                reject(new Error(`Failed to send message to Teams after ${retries} retries`));
            }
        });

        req.write(teamsPayload);
        req.end();
    });
}

function formatAlarmTime(iso) {
  if (!iso) return 'unknown';
  const d = new Date(iso);
  if (isNaN(d)) return iso;
  return d.toISOString().replace('T', ' ').replace('Z', ' UTC');
}

function buildJiraIssueEndpoint(rawUrl) {
  const trimmed = rawUrl.trim();
  const withoutTrailing = trimmed.replace(/\/+$/, '');
  const withScheme = /^https?:\/\//i.test(withoutTrailing)
    ? withoutTrailing
    : `https://${withoutTrailing}`;
  return `${withScheme}/rest/api/2/issue`;
}

function buildJiraSearchEndpoint(rawUrl) {
    const trimmed = rawUrl.trim();
    const withoutTrailing = trimmed.replace(/\/+$/, '');
    const withScheme = /^https?:\/\//i.test(withoutTrailing)
        ? withoutTrailing
        : `https://${withoutTrailing}`;
    return `${withScheme}/rest/api/2/search`;
}

function escapeForJql(value) {
    if (!value) return '';
    return String(value).replace(/["\\]/g, '\\$&');
}

async function hasExistingJira({
    searchEndpoint,
    authHeader,
    source,
    alarmName,
    accountName,
    description,
    environment,
    boundedContext,
    accountId,
    finding,
}) {
    try {
        const jqlParts = [
            'project = CCM',
            'statusCategory != Done',
        ];

        if (source === 'notify.envDestroyFailed') {
            jqlParts.push('summary ~ "Env failed to destroy"');
            if (environment) {
                jqlParts.push(`description ~ "${escapeForJql(environment)}"`);
            }
            if (boundedContext) {
                jqlParts.push(`description ~ "${escapeForJql(boundedContext)}"`);
            }
            if (accountId) {
                jqlParts.push(`description ~ "${escapeForJql(accountId)}"`);
            }
        } else if (source === 'notify.sechub' && finding) {
            const { severity, resourceType, resourceId, title, id } = finding || {};

            if (accountName) {
                jqlParts.push(`summary ~ "${escapeForJql(accountName)}"`);
            }
            if (severity) {
                jqlParts.push(`summary ~ "${escapeForJql(severity)}"`);
            }
            if (resourceType) {
                jqlParts.push(`summary ~ "${escapeForJql(resourceType)}"`);
            }
            const identity = resourceId || title || id;
            if (identity) {
                jqlParts.push(`description ~ "${escapeForJql(identity)}"`);
            }
        } else {
            const descriptionSnippet = (description || '').slice(0, 200);

            if (alarmName) {
                jqlParts.push(`summary ~ "${escapeForJql(alarmName)}"`);
            }
            if (accountId) {
                jqlParts.push(`description ~ "${escapeForJql(accountId)}"`);
            }
            if (descriptionSnippet) {
                jqlParts.push(`description ~ "${escapeForJql(descriptionSnippet)}"`);
            }
        }

        const jql = jqlParts.join(' AND ');
        const label = source || 'unknown';

        console.log(`[Jira:search:${label}] endpoint="${searchEndpoint}" jql="${jql}"`);

        const response = await axios.get(searchEndpoint, {
            params: {
                jql,
                maxResults: 1,
                fields: 'key',
            },
            headers: {
                Authorization: authHeader,
                'Content-Type': 'application/json',
            },
            timeout: 10000,
        });

        const total = response?.data?.total ?? 0;
        console.log(`[Jira:search:${label}:result] total=${total}`);
        return total > 0;
    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        const label = source || 'unknown';
        console.error(`[Jira:search:${label}:error] message="${msg}"`);
        return false;
    }
}

async function createOrSkipJira({
    issueEndpoint,
    searchEndpoint,
    authHeader,
    source,
    buildInput,
}) {
    const {
        alarmName,
        accountName,
        description,
        environment,
        boundedContext,
        accountId,
        finding,
    } = buildInput;

    const alreadyExists = await hasExistingJira({
        searchEndpoint,
        authHeader,
        source,
        alarmName,
        accountName,
        description,
        environment,
        boundedContext,
        accountId,
        finding,
    });

    if (alreadyExists) {
        const scope = finding ? 'Security Hub finding' : 'event';
        console.log(`[Jira:create:skip] Existing Jira found for this ${scope} (source=${source})`);
        return;
    }

    const issueData = buildJiraIssueData(buildInput);

    const payloadStr = JSON.stringify(issueData);
    console.log(payloadStr);
    console.log(
        `[Jira:issue:payload] project=${issueData.fields.project.key} summary="${issueData.fields.summary}" size=${payloadStr.length}`,
    );

    try {
        const response = await axios.post(issueEndpoint, issueData, {
            headers: {
                Authorization: authHeader,
                'Content-Type': 'application/json',
            },
            timeout: 10000,
        });

        if (response.status < 200 || response.status > 299) {
            const bodyPreview = JSON.stringify(response.data).slice(0, 200);
            console.error(
                `[Jira:issue:non_success] status=${response.status} statusText="${response.statusText}" bodyPreview="${bodyPreview}"`,
            );
            return;
        }

        console.log(`[Jira:issue:created] status=${response.status} key=${response.data?.key}`);
    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        console.error(`[Jira:issue:error] message="${msg}"`);
    }
}

function buildJiraIssueData(input) {
    const { alarmName, environment, accountName, accountId, boundedContext, component, description, region, time, source, finding } = input;
  if (source === "notify.envDestroyFailed") {
    if (!environment || !accountId || !boundedContext || !component) {
        console.warn('environment, accountId, boundedContext or component is missing or undefined');
        throw new Error('Necessary fields missing to raise JIRA issue for PR Environment Destroy')
    }
    return {
      fields: {
        project: { key: 'CCM' },
        summary: `Env failed to destroy: ${environment || 'unknown'} for ${boundedContext || 'unknown'} Bounded Context`,
        description: [
          ` * *Time of the alarm:* _${formatAlarmTime(time)}_`,
          ` * *Account Id:* _${accountId || 'unknown'}_`,
          ` * *Env name:* _${environment || 'unknown'}_`,
          ` * *Bounded Context:* _${boundedContext || 'unknown'}_`,
          ` * *Component:* _${component || 'unknown'}_`,
        ].join('\n'),
        issuetype: { name: 'Task' },
                priority: { name: 'Low' },
        components: [{ name: 'Platform' }],
      },
    };
    } else if (source === "notify.sechub") {
        if (!accountName || !finding) {
            console.warn('accountName or finding is missing or undefined for notify.sechub');
            throw new Error('Necessary fields missing to raise JIRA issue for Security Hub finding');
        }

        const severity = finding.severity || 'UNKNOWN';
        const resourceType = finding.resourceType || 'Unknown resource type';

        // Map Security Hub severity to a valid Jira priority name.
        // Jira project CCM uses standard names like "High" rather than "HIGH"/"CRITICAL".
        const severityMap = {
            LOW: 'Low',
            MEDIUM: 'Medium',
            CRITICAL: 'High',
            HIGH: 'High'
        };

        const normalisedSeverity = String(severity).toUpperCase();
        const jiraPriorityName = severityMap[normalisedSeverity] ?? 'High';

        return {
            fields: {
                project: { key: 'CCM' },
                summary: `Security Hub ${severity} finding on ${resourceType} in ${accountName}`,
                description: [
                    'This ticket has been raised for an individual Security Hub finding reported in the *Notify Security* Teams channel.',
                    'h2. Details',
                    ` * *Time of the alarm:* _${formatAlarmTime(time)}_`,
                    ` * *Account Name:* _${accountName || 'unknown'}_`,
                    ` * *Severity:* _${severity}_`,
                    ` * *Resource type:* _${resourceType}_`,
                    ` * *Resource ID:* _${finding.resourceId || 'n/a'}_`,
                    ` * *Finding title:* _${finding.title || 'n/a'}_`,
                    finding.description ? '' : null,
                    finding.description ? 'h3. Finding description' : null,
                    finding.description || null,
                ].filter(Boolean).join('\n'),
                issuetype: { name: 'Task' },
                priority: { name: jiraPriorityName },
                components: [{ name: 'Platform' }],
            },
        };
  } else {
  // Default for other sources
  if (!alarmName) {
        console.warn('alarmName is missing or undefined');
        throw new Error('Necessary fields missing to raise JIRA issue for Alarms')
  }
  return {
      fields: {
        project: { key: 'CCM' },
        summary: `Alarm triggered: ${alarmName ?? 'Unknown alarm'}`,
        description: [
            `This ticket has been raised for a production alarm reported in the *Alerts* Teams channel.`,
            'h2. Details',
            ` * *Time of the alarm:* _${formatAlarmTime(time)}_`,
            ` * *Account ID:* _${accountId || 'unknown'}_`,
            ` * *Alarm name:* _${alarmName || 'unknown'}_`,
            ` * *Error message:* _${description || 'n/a'}_`,
            ` * *CloudWatch console link:* https://console.aws.amazon.com/cloudwatch/home?region=${encodeURIComponent(
            region || 'unknown-region'
            )}#alarmsV2:alarm/${encodeURIComponent(alarmName || '')}`,
        ].join('\n'),
        issuetype: { name: 'Task' },
        components: [{ name: 'Support' }],
      },
    };
  }
}

async function createJiraTicket(event) {
  const alarmName = event?.detail?.alarmName;
  const environment = event?.detail?.environment;
    const accountName = event?.detail?.accountName;
    const source = event.source;
  console.log(`Jira:create:start`);
    const alertsToJira = process.env.ALERTS_TO_JIRA === 'true';
    if (!alertsToJira) {
        console.log(
            `[Jira:create:skip] We don't intend to create Jira tickets for alerts in this environment – skipping Jira creation`,
        );
        return;
    }

  // Replace with your own credentials retrieval logic
  const urlPath = process.env.JIRA_URL_PARAM_NAME;
  const patPath = process.env.JIRA_PAT_PARAM_NAME;

  const url = await getJiraParam(urlPath);
  const patToken = await getJiraParam(patPath);

  console.log('Jira:credentials:fetched');

  if (!url || !patToken) {
    console.error(`[Jira:credentials:missing] haveUrl=${!!url} havePat=${!!patToken}`);
    return;
  }

  const issueEndpoint = buildJiraIssueEndpoint(url);
  const searchEndpoint = buildJiraSearchEndpoint(url);
  console.log(`[Jira:issue:endpoint] url="${issueEndpoint}"`);

    const authHeader = `Bearer ${patToken}`;

    if (source === "notify.sechub" && Array.isArray(event.detail?.highCriticalFindings) && event.detail.highCriticalFindings.length > 0) {
        const findings = event.detail.highCriticalFindings;

        for (const finding of findings) {
            await createOrSkipJira({
                issueEndpoint,
                searchEndpoint,
                authHeader,
                source,
                buildInput: {
                    source,
                    accountName,
                    time: event.time,
                    finding,
                },
            });
        }

        return;
    }

    const rawDescription = event.detail?.configuration?.description;
    const description = rawDescription;

    await createOrSkipJira({
        issueEndpoint,
        searchEndpoint,
        authHeader,
        source,
        buildInput: {
            alarmName,
            environment,
            accountName,
            accountId: event.detail?.accountId || event.account,
            boundedContext: event.detail?.boundedContext,
            component: event.detail?.component,
            description,
            detail: event.detailType || null,
            region: event.region,
            time: event.time,
            source,
        },
    });

    return;
}

async function getJiraParam(paramName) {
  try {
    const command = new GetParameterCommand({ Name: paramName, WithDecryption: true });
    const response = await ssmClient.send(command);
    const value = response?.Parameter?.Value;
    if (!value) {
      throw new Error(`SSM parameter ${paramName} has no Value property`);
    }
    return value;
  } catch (err) {
    throw new Error(`Failed to read SSM parameter ${paramName}: ${err}`);
  }
}

module.exports = {
    getTeamsWebhookUrl,
    sendTeamsMessage,
    extractSecurityHubSections,
    createJiraTicket,
    buildJiraIssueData,
    handler: async (event) => {
        console.log("Event Received:", JSON.stringify(event, null, 2));

        let parameterName;
        if (event.source === "notify.envDestroyFailed") {
            await createJiraTicket(event);
            return;
        } else if (event.source === "aws.cloudwatch") {
            parameterName = process.env.TEAMS_WEBHOOK_CLOUDWATCH_SSM_PARAM;
        } else if (event.source === "aws.backup") {
            parameterName = process.env.TEAMS_WEBHOOK_ALERTS_BACKUP_ERRORS_SSM_PARAM;
        } else if (event.source === "notify.sechub") {
            parameterName = process.env.TEAMS_WEBHOOK_ALERTS_SECURITY_SSM_PARAM;
        } else {
            console.error("Unhandled event source:", event.source);
            return;
        }

        const TEAMS_WEBHOOK_URL = await getTeamsWebhookUrl(parameterName);
        if (!TEAMS_WEBHOOK_URL) {
            console.error("Failed to retrieve Teams Webhook URL from SSM");
            return;
        }

        console.log("Teams Webhook URL:", TEAMS_WEBHOOK_URL);

        const url = new URL(TEAMS_WEBHOOK_URL);

        try {
            const detail = event.detail;
            console.log("Event Detail:", detail);

            let title, formattedMessage;

            if (event.source === "aws.cloudwatch") {
                const alarmName = detail.alarmName;
                const state = detail.state.value;
                const reason = detail.state.reason;
                const accountId = event.account;
                const statusEmoji = state === 'ALARM' ? '🔴' : state === 'OK' ? '🟢' : '';

                title = `${statusEmoji} CloudWatch Alarm: ${alarmName} - ${state}`;
                formattedMessage = `
**Alarm Name:** ${alarmName}

**AccountID:** ${accountId}

**State:** ${state}

**Reason:** ${reason}
                `.trim();
                await createJiraTicket(event);
            } else if (event.source === "aws.backup") {
                const jobId = detail.backupJobId || detail.restoreJobId || detail.copyJobId;
                const state = detail.state;
                const statusEmoji = state === 'FAILED' ? '🔴' : state === 'ABORTED' ? '⚠️' : '';

                title = `${statusEmoji} AWS Backup Job: ${jobId} - ${state}`;
                formattedMessage = `
**Job ID:** ${jobId}

**State:** ${state}

**Status Message:** ${detail.statusMessage || "N/A"}
                `.trim();
            } else if (event.source === "notify.sechub") {
                title = `🛡️ Security Hub Notification: ${event.account} (${detail.accountName})`;
                formattedMessage = extractSecurityHubSections(detail.message);
                await createJiraTicket(event);
            }

            const teamsPayload = JSON.stringify({
                title: title,
                text: formattedMessage,
            });

            await sendTeamsMessage(teamsPayload, url);
        } catch (error) {
            console.error("Error processing event:", error);
        }
    }
};
