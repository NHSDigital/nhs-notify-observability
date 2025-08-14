const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");
const https = require('https');
const { getTeamsWebhookUrl, sendTeamsMessage, handler, extractSecurityHubSections } = require('../index');

jest.mock('@aws-sdk/client-ssm');
jest.mock('https');

describe('getTeamsWebhookUrl', () => {
    beforeEach(() => {
        process.env.TEAMS_WEBHOOK_ALERTS_SSM_PARAM = 'test-param';
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should return the webhook URL from SSM', async () => {
        const mockResponse = {
            Parameter: {
                Value: 'https://example.com/webhook'
            }
        };
        SSMClient.prototype.send.mockResolvedValue(mockResponse);

        const url = await getTeamsWebhookUrl();
        expect(url).toBe('https://example.com/webhook');
    });

    it('should return null if no parameter name is found in environment variables', async () => {
        delete process.env.TEAMS_WEBHOOK_ALERTS_SSM_PARAM;

        const url = await getTeamsWebhookUrl();
        expect(url).toBeNull();
    });

    it('should return null if SSM parameter is not found', async () => {
        const mockResponse = {};
        SSMClient.prototype.send.mockResolvedValue(mockResponse);

        const url = await getTeamsWebhookUrl();
        expect(url).toBeNull();
    });

    it('should return null if there is an error retrieving the SSM parameter', async () => {
        SSMClient.prototype.send.mockRejectedValue(new Error('SSM error'));

        const url = await getTeamsWebhookUrl();
        expect(url).toBeNull();
    });
});

describe('sendTeamsMessage', () => {
    const url = new URL('https://example.com/webhook');
    const teamsPayload = JSON.stringify({ title: 'Test', text: 'Test message' });

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should send a message to Teams successfully', async () => {
        const mockRequest = {
            on: jest.fn(),
            write: jest.fn(),
            end: jest.fn()
        };
        https.request.mockImplementation((options, callback) => {
            callback({
                statusCode: 200,
                on: (event, handler) => {
                    if (event === 'data') handler('response data');
                    if (event === 'end') handler();
                }
            });
            return mockRequest;
        });

        await expect(sendTeamsMessage(teamsPayload, url)).resolves.toBeUndefined();
        expect(mockRequest.write).toHaveBeenCalledWith(teamsPayload);
        expect(mockRequest.end).toHaveBeenCalled();
    });

    it('should retry sending a message to Teams if it fails', async () => {
        const mockRequest = {
            on: jest.fn(),
            write: jest.fn(),
            end: jest.fn()
        };
        https.request.mockImplementation((options, callback) => {
            callback({
                statusCode: 500,
                on: (event, handler) => {
                    if (event === 'data') handler('response data');
                    if (event === 'end') handler();
                }
            });
            return mockRequest;
        });

        await expect(sendTeamsMessage(teamsPayload, url, 1)).rejects.toThrow('Failed to send message to Teams after 0 retries');
        expect(mockRequest.write).toHaveBeenCalledTimes(2);
        expect(mockRequest.end).toHaveBeenCalledTimes(2);
    }, 10000); // Increase timeout to 10 seconds

    it('should handle request errors and retry', async () => {
        const mockRequest = {
            on: jest.fn((event, handler) => {
                if (event === 'error') handler(new Error('Request error'));
            }),
            write: jest.fn(),
            end: jest.fn()
        };
        https.request.mockReturnValue(mockRequest);

        await expect(sendTeamsMessage(teamsPayload, url, 1)).rejects.toThrow('Failed to send message to Teams after 0 retries');
        expect(mockRequest.write).toHaveBeenCalledTimes(2);
        expect(mockRequest.end).toHaveBeenCalledTimes(2);
    }, 10000); // Increase timeout to 10 seconds

    it('should handle request timeouts and retry', async () => {
        const mockRequest = {
            on: jest.fn((event, handler) => {
                if (event === 'timeout') handler();
            }),
            write: jest.fn(),
            end: jest.fn(),
            abort: jest.fn()
        };
        https.request.mockReturnValue(mockRequest);

        await expect(sendTeamsMessage(teamsPayload, url, 1)).rejects.toThrow('Failed to send message to Teams after 0 retries');
        expect(mockRequest.write).toHaveBeenCalledTimes(2);
        expect(mockRequest.end).toHaveBeenCalledTimes(2);
        expect(mockRequest.abort).toHaveBeenCalledTimes(2);
    }, 10000); // Increase timeout to 10 seconds
});

describe('handler', () => {
    beforeEach(() => {
        process.env.TEAMS_WEBHOOK_ALERTS_SSM_PARAM = 'test-param';
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    it('should handle CloudWatch alarm events and send a message to Teams', async () => {
        const mockResponse = {
            Parameter: {
                Value: 'https://example.com/webhook'
            }
        };
        SSMClient.prototype.send.mockResolvedValue(mockResponse);

        const mockRequest = {
            on: jest.fn(),
            write: jest.fn(),
            end: jest.fn()
        };
        https.request.mockImplementation((options, callback) => {
            callback({
                statusCode: 200,
                on: (event, handler) => {
                    if (event === 'data') handler('response data');
                    if (event === 'end') handler();
                }
            });
            return mockRequest;
        });

        const event = {
            detail: {
                alarmName: 'TestAlarm',
                state: {
                    value: 'ALARM',
                    reason: 'Threshold Crossed'
                }
            }
        };

        await handler(event);

        expect(SSMClient.prototype.send).toHaveBeenCalledWith(expect.any(GetParameterCommand));
        expect(mockRequest.write).toHaveBeenCalled();
        expect(mockRequest.end).toHaveBeenCalled();
    });

    it('should log an error if there is an issue processing the event', async () => {
        const mockResponse = {
            Parameter: {
                Value: 'https://example.com/webhook'
            }
        };
        SSMClient.prototype.send.mockResolvedValue(mockResponse);

        const mockRequest = {
            on: jest.fn(),
            write: jest.fn(),
            end: jest.fn()
        };
        https.request.mockImplementation((options, callback) => {
            callback({
                statusCode: 200,
                on: (event, handler) => {
                    if (event === 'data') handler('response data');
                    if (event === 'end') handler();
                }
            });
            return mockRequest;
        });

        const event = {
            detail: {
                alarmName: 'TestAlarm',
                state: {
                    value: 'ALARM',
                    reason: 'Threshold Crossed'
                }
            }
        };

        const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

        SSMClient.prototype.send.mockRejectedValue(new Error('SSM error'));

        await handler(event);

        expect(consoleErrorSpy).toHaveBeenCalledWith(expect.any(String), expect.any(Error));
        consoleErrorSpy.mockRestore();
    });
});

describe('extractSecurityHubSections', () => {
    it('should format sections with findings on new lines and sections separated', () => {
        const input = 
            "Total Security Hub Findings grouped by Severity. Failed controls only.\n--------------------------------------------------\nMEDIUM 22\nLOW 21\nCRITICAL 7\nHIGH 6\n--------------------------------------------------\n\n\nNew Security Hub Findings from the last 5 days, grouped by Severity. Failed controls only.\n--------------------------------------------------\nCRITICAL 1\n--------------------------------------------------\n\n\nTotal Security Hub Findings grouped by Resource Type. Failed controls only.\n--------------------------------------------------\nAwsAccount 23\nAwsS3Bucket 8\nAwsEc2Vpc 6\nAwsIamPolicy 6\nAwsKmsKey 4\nAwsIamRole 3\nAwsCloudTrailTrail 2\nAwsEc2SecurityGroup 2\nAwsDynamoDbTable 1\nAwsEc2VPCBlockPublicAccessOptions 1\n--------------------------------------------------\n\n";

        const expected =
`**Total Security Hub Findings grouped by Severity. Failed controls only.**<br>CRITICAL                       7<br>HIGH                           6<br>LOW                            21<br>MEDIUM                         22<br><br><br>**New Security Hub Findings from the last 5 days, grouped by Severity. Failed controls only.**<br>CRITICAL                       1<br><br><br>**Total Security Hub Findings grouped by Resource Type. Failed controls only.**<br>AwsAccount                     23<br>AwsCloudTrailTrail             2<br>AwsDynamoDbTable               1<br>AwsEc2SecurityGroup            2<br>AwsEc2Vpc                      6<br>AwsEc2VPCBlockPublicAccessOptions 1<br>AwsIamPolicy                   6<br>AwsIamRole                     3<br>AwsKmsKey                      4<br>AwsS3Bucket                    8<br>`;

        expect(extractSecurityHubSections(input)).toBe(expected);
    });

    it('should return empty string for empty input', () => {
        expect(extractSecurityHubSections('')).toBe('');
    });

    it('should handle input with only headers and no findings', () => {
        const input = "Total Security Hub Findings grouped by Severity. Failed controls only.\n";
        expect(extractSecurityHubSections(input)).toBe('');
    });

    it('should handle input with one section', () => {
        const input = "Total Security Hub Findings grouped by Severity. Failed controls only.\nMEDIUM 2\nLOW 1";
        const expected = "**Total Security Hub Findings grouped by Severity. Failed controls only.**<br>LOW                            1<br>MEDIUM                         2<br>";
        expect(extractSecurityHubSections(input)).toBe(expected);
    });
});
