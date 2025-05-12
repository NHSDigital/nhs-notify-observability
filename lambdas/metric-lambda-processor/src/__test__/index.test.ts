import { readFileSync } from 'fs';
import { handler, transformJsonMetricEvent } from '../index';
import { metricEventType } from '../types';

function getEventFromLocalFile(eventType: string): metricEventType {
  const inputEvent = `test-events/${eventType}.json`;
  return JSON.parse(readFileSync(inputEvent, 'utf8'));
}

describe('test handler', () => {
  afterEach(() => {
    jest.resetAllMocks();
    process.env.METRICS_OUTPUT_FORMAT = '';
    process.env.SPLUNK_CLOUDWATCH_SOURCETYPE = '';
  });
  beforeEach(() => {
    process.env.METRICS_OUTPUT_FORMAT = 'json';
    process.env.SPLUNK_CLOUDWATCH_SOURCETYPE = 'aws:cloudwatch:metric';
  });
  it('succeeds on generating metric data for putting to firehose delivery stream', async () => {
    const expectedResultEntryOne = {
      event: {
        metric_stream_name: 'test-cw-metric-stream',
        account_id: '112543817624',
        region: 'us-west-2',
        namespace: 'AWS/EC2',
        metric_name: 'StatusCheckFailed',
        timestamp: 1617727740000,
        unit: 'Count',
        InstanceId: 'i-0e436f6848d37dd42',
        metric: 'StatusCheckFailed',
        SampleCount: 1,
        Sum: 0,
        Maximum: 0,
        Minimum: 0,
        Average: 0,
      },
      source: 'us-west-2:AWS/EC2',
      sourcetype: 'aws:cloudwatch:metric',
      time: 1617727740000,
    };

    const result = await handler(getEventFromLocalFile('event'));
    const jsonData = Buffer.from(result.records[0].data, 'base64').toString(
      'utf-8'
    );
    const jsonResult = JSON.parse(jsonData);

    expect(jsonResult[0]).toEqual(expectedResultEntryOne);
  });

  it('fails on invalid output format env var', async () => {
    process.env.METRICS_OUTPUT_FORMAT = 'notJSON';
    await expect(handler(getEventFromLocalFile('event'))).rejects.toThrowError(
      'Invalid METRICS_OUTPUT_FORMAT value. Set to json'
    );
  });

  it('succeeds on transforming json event', async () => {
    const expectedResultEntryOne = {
      event: {
        metric_stream_name: 'test-cw-metric-stream',
        account_id: '112543817624',
        region: 'us-west-2',
        namespace: 'AWS/EC2',
        metric_name: 'StatusCheckFailed_Instance',
        timestamp: 1617727740000,
        unit: 'Count',
        InstanceId: 'i-059912c19432998d8',
        metric: 'StatusCheckFailed_Instance',
        SampleCount: 2,
        Sum: 2,
        Maximum: 0,
        Minimum: 0,
        Average: 1,
      },
      source: 'us-west-2:AWS/EC2',
      sourcetype: 'aws:cloudwatch:metric',
      time: 1617727740000,
    };

    const result = transformJsonMetricEvent([
      '{"metric_stream_name":"test-cw-metric-stream","account_id":"112543817624","region":"us-west-2","namespace":"AWS/EC2","metric_name":"StatusCheckFailed","dimensions":{"InstanceId":"i-0e436f6848d37dd42"},"timestamp":1617727740000,"value":{"count":1.0,"sum":0.0,"max":0.0,"min":0.0},"unit":"Count"}',
      '{"metric_stream_name":"test-cw-metric-stream","account_id":"112543817624","region":"us-west-2","namespace":"AWS/EC2","metric_name":"StatusCheckFailed_Instance","dimensions":{"InstanceId":"i-059912c19432998d8"},"timestamp":1617727740000,"value":{"count":2.0,"sum":2.0,"max":0.0,"min":0.0},"unit":"Count"}',
    ]);

    expect(result[1]).toEqual(expectedResultEntryOne);
  });

  it('fails on transforming json event', async () => {
    expect(() => {
      transformJsonMetricEvent(['test']);
    }).toThrowError(
      'Transform JSON error:: SyntaxError: Unexpected token e in JSON at position 1'
    );
  });
});
