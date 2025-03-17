const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");
const https = require('https');

const ssmClient = new SSMClient({ region: "eu-west-2" });

async function getTeamsWebhookUrl(parameterName) {
    console.log("SSM Parameter Name:", parameterName);
    if (!parameterName) {
        console.error("No SSM parameter name found in environment variables");
        return null;
    }
    try {
        const command = new GetParameterCommand({
            Name: parameterName,
            WithDecryption: true,
        });
        const response = await ssmClient.send(command);
        console.log("SSM Parameter Response:", response);
        if (!response.Parameter) {
            console.error("SSM Parameter not found");
            return null;
        }
        return response.Parameter.Value || null;
    } catch (error) {
        console.error("Error retrieving SSM Parameter:", error);
        console.error("Error details:", error.message);
        console.error("Error stack:", error.stack);
        return null;
    }
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

        console.log("Request options:", options);
        console.log("Payload:", teamsPayload);

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

module.exports = {
    getTeamsWebhookUrl,
    sendTeamsMessage,
    handler: async (event) => {
        console.log("Event Received:", JSON.stringify(event, null, 2));

        let parameterName;
        if (event.source === "aws.cloudwatch") {
            parameterName = process.env.TEAMS_WEBHOOK_CLOUDWATCH_SSM_PARAM;
        } else if (event.source === "aws.backup") {
            parameterName = process.env.TEAMS_WEBHOOK_ALERTS_BACKUP_ERRORS_SSM_PARAM;
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
