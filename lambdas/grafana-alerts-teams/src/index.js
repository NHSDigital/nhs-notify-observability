const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");
const https = require('https');

const ssmClient = new SSMClient({ region: "eu-west-2" });

async function getTeamsWebhookUrl() {
    const parameterName = process.env.TEAMS_WEBHOOK_ALERTS_SSM_PARAM;
    console.log("SSM Parameter Name:", parameterName); // Log the parameter name
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
        console.log("SSM Parameter Response:", response); // Log the response
        if (!response.Parameter) {
            console.error("SSM Parameter not found");
            return null;
        }
        return response.Parameter.Value || null;
    } catch (error) {
        console.error("Error retrieving SSM Parameter:", error);
        console.error("Error details:", error.message); // Log the error message
        console.error("Error stack:", error.stack); // Log the error stack
        return null;
    }
}

exports.handler = async (event) => {
    console.log("SNS Event Received:", JSON.stringify(event, null, 2));

    const TEAMS_WEBHOOK_URL = await getTeamsWebhookUrl();
    if (!TEAMS_WEBHOOK_URL) {
        console.error("Failed to retrieve Teams Webhook URL from SSM");
        return;
    }

    console.log("Teams Webhook URL:", TEAMS_WEBHOOK_URL);

    for (const record of event.Records) {
        try {
            const snsMessage = JSON.parse(record.Sns.Message);
            console.log("SNS Message:", snsMessage);

            // Extract and format the message
            const alert = snsMessage.alerts[0];
            const formattedMessage = `
**Domain:** ${alert.labels.grafana_folder}

**Status:** ${alert.status}

**Grafana URL:** ${snsMessage.externalURL}

**Silence Link:** ${alert.silenceURL}

[View Alert in Grafana](${alert.generatorURL})

${alert.generatorURL}
            `;

            // Prepare the payload for Microsoft Teams
            const teamsPayload = JSON.stringify({
                title: `Alert: ${alert.labels.alertname}`,
                text: formattedMessage,
            });

            const url = new URL(TEAMS_WEBHOOK_URL);

            const options = {
                hostname: url.hostname,
                path: url.pathname,
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Length': teamsPayload.length,
                },
                timeout: 5000, // 5 seconds timeout
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
                    } else {
                        console.error(`Failed to send message to Teams: ${res.statusCode} ${res.statusMessage}`);
                    }
                });
            });

            req.on('error', (error) => {
                console.error("Error sending message to Teams:", error);
            });

            req.on('timeout', () => {
                req.abort();
                console.error("Request timed out");
            });

            req.write(teamsPayload);
            req.end();
        } catch (error) {
            console.error("Error processing record:", error);
        }
    }
};
