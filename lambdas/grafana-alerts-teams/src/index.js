const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");
const https = require('https');

const ssmClient = new SSMClient({ region: "eu-west-2" });

async function getTeamsWebhookUrl() {
    const parameterName = process.env.TEAMS_WEBHOOK_ALERTS_SSM_PARAM;
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
        console.log("SNS Event Received:", JSON.stringify(event, null, 2));

        const TEAMS_WEBHOOK_URL = await getTeamsWebhookUrl();
        if (!TEAMS_WEBHOOK_URL) {
            console.error("Failed to retrieve Teams Webhook URL from SSM");
            return;
        }

        console.log("Teams Webhook URL:", TEAMS_WEBHOOK_URL);

        const url = new URL(TEAMS_WEBHOOK_URL);

        for (const record of event.Records) {
            try {
                const snsMessage = JSON.parse(record.Sns.Message);
                console.log("SNS Message:", snsMessage);

                const alert = snsMessage.alerts[0];
                const status = alert.status.toUpperCase();
                const statusEmoji = status === 'FIRING' ? '🔴' : status === 'RESOLVED' ? '🟢' : '';

                const formattedMessage = `
**Domain:** ${alert.labels.grafana_folder}

**Grafana URL:** ${snsMessage.externalURL}

**Silence Link:** ${alert.silenceURL}
                `.trim();

                const teamsPayload = JSON.stringify({
                    title: `${statusEmoji} Alert: ${alert.labels.alertname} - ${status}`,
                    text: formattedMessage,
                });

                await sendTeamsMessage(teamsPayload, url);
            } catch (error) {
                console.error("Error processing record:", error);
            }
        }
    }
};
