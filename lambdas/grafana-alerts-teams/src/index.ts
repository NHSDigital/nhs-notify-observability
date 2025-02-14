import { SNSEvent } from "aws-lambda";
import { SSMClient, GetParameterCommand } from "@aws-sdk/client-ssm";

const ssmClient = new SSMClient({ region: "eu-west-2" }); // Adjust region if needed

// Fetch the Teams Webhook URL from SSM Parameter
async function getTeamsWebhookUrl(): Promise<string | null> {
    try {
        const command = new GetParameterCommand({
            Name: "/myapp/teams-webhook-url", // Replace with your SSM Parameter Name
            WithDecryption: true,
        });
        const response = await ssmClient.send(command);
        return response.Parameter?.Value || null;
    } catch (error) {
        console.error("Error retrieving SSM Parameter:", error);
        return null;
    }
}

export const handler = async (event: SNSEvent): Promise<void> => {
    console.log("SNS Event Received:", JSON.stringify(event, null, 2));

    // Retrieve the webhook URL from SSM
    const TEAMS_WEBHOOK_URL = await getTeamsWebhookUrl();
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
