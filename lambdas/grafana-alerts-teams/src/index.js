const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");

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
        return response.Parameter?.Value || null;
    } catch (error) {
        console.error("Error retrieving SSM Parameter:", error);
        return null;
    }
}

// Retrieve the Teams Webhook URL once and store it in a variable
let TEAMS_WEBHOOK_URL;
(async () => {
    TEAMS_WEBHOOK_URL = await getTeamsWebhookUrl();
    console.log("Teams Webhook URL:", TEAMS_WEBHOOK_URL); // Log the webhook URL
})();

exports.handler = async (event) => {
    console.log("SNS Event Received:", JSON.stringify(event, null, 2));

    if (!TEAMS_WEBHOOK_URL) {
        console.error("Failed to retrieve Teams Webhook URL from SSM");
        return;
    }

    for (const record of event.Records) {
        const snsMessage = record.Sns.Message;
        console.log("SNS Message:", snsMessage);

        // Prepare the payload for Microsoft Teams
        const teamsPayload = {
            text: `New SNS Notification: ${snsMessage}`,
        };

        try {
            const response = await fetch(TEAMS_WEBHOOK_URL, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(teamsPayload),
            });

            if (!response.ok) {
                console.error(`Failed to send message to Teams: ${response.statusText}`);
            } else {
                console.log("Message successfully sent to Microsoft Teams");
            }
        } catch (error) {
            console.error("Error sending message to Teams:", error);
        }
    }
};
