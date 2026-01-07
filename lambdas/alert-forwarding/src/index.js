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

function buildJiraIssueData(input) {
  const { alarmName, environment, accountName, accountId, boundedContext, component, description, detail, region, time, source } = input;
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
        components: [{ name: 'Support' }, { name: 'Platform' }],
      },
    };
  } else {
  // Default for other sources
  if (!alarmName || !accountName) {
        console.warn('alarmName or accountName is missing or undefined');
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
            ` * *Account Name:* _${accountName || 'unknown'}_`,
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
  console.log(`[Jira:issue:endpoint] url="${issueEndpoint}"`);

  const issueData = buildJiraIssueData({
    alarmName,
    environment,
    accountName,
    accountId: event.detail?.accountId,
    boundedContext: event.detail?.boundedContext,
    component: event.detail?.component,
    description: event.detail?.configuration?.description,
    detail: event.detailType || null,
    region: event.region,
    time: event.time,
    source,
  });

  const payloadStr = JSON.stringify(issueData);
  console.log(payloadStr)
  console.log(`[Jira:issue:payload] project=${issueData.fields.project.key} summary="${issueData.fields.summary}" size=${payloadStr.length}`);

  const authHeader = `Bearer ${patToken}`;

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
      console.error(`[Jira:issue:non_success] status=${response.status} statusText="${response.statusText}" bodyPreview="${bodyPreview}"`);
      return;
    }

    console.log(`[Jira:issue:created] status=${response.status} key=${response.data?.key}`);
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    console.error(`[Jira:issue:error] message="${msg}"`);
  }

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
                const statusEmoji = state === 'ALARM' ? '🔴' : state === 'OK' ? '🟢' : '';

                title = `${statusEmoji} CloudWatch Alarm: ${alarmName} - ${state}`;
                formattedMessage = `
**Alarm Name:** ${alarmName}

**State:** ${state}

**Reason:** ${reason}
                `.trim();
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
