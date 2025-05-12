/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { logger } from '@nhs-notify-observability/utils-logger';
import { cloneDeep } from 'lodash';
import { metricEventType, recordEntry } from './types';

export function transformJsonMetricEvent(metrics: string[]): unknown[] {
  try {
    const events: unknown[] = [];
    metrics.forEach((metricString: string) => {
      if (metricString !== '') {
        const metric = JSON.parse(metricString);
        const metricEvent = cloneDeep(metric);
        // eslint-disable-next-line array-callback-return
        Object.entries(metricEvent.dimensions).map(([key, value]) => {
          metricEvent[key] = value;
        });
        delete metricEvent.dimensions;
        metricEvent.metric = metricEvent.metric_name; // adding this extra field as metric_name field gets clubbed with statistics on splunk side for some reason, and doesn't let us filter properly
        Object.entries(metricEvent.value)
          // eslint-disable-next-line array-callback-return
          .map(([key, value]) => {
            if (key === 'count') {
              metricEvent.SampleCount = value;
            }
            if (key === 'sum') {
              metricEvent.Sum = value;
            }
            if (key === 'max') {
              metricEvent.Maximum = value;
            }
            if (key === 'min') {
              metricEvent.Minimum = value;
            }
          });
        metricEvent.Average = metricEvent.Sum / metricEvent.SampleCount;
        delete metricEvent.value;
        let sourcetype = 'aws:cloudwatch';
        if (process.env.SPLUNK_CLOUDWATCH_SOURCETYPE) {
          sourcetype = process.env.SPLUNK_CLOUDWATCH_SOURCETYPE;
        }
        const event = {
          event: metricEvent,
          source: `${metricEvent.region}:${metricEvent.namespace}`,
          sourcetype,
          time: metricEvent.timestamp,
        };
        events.push(event);
      }
    });

    return events;
  } catch (err) {
    logger.error({
      eventCode: 'MLP2003',
      err: 'Transform JSON error',
    });
    throw new Error(`Transform JSON error:: ${err}`);
  }
}

export async function handler(event: metricEventType): Promise<void | any> {
  try {
    const metrics: any[] = [];
    const { records } = event;
    if (
      process.env.METRICS_OUTPUT_FORMAT &&
      process.env.METRICS_OUTPUT_FORMAT === 'json'
    ) {
      records.forEach(async (record: recordEntry) => {
        const recordData = record.data;
        const decodedData = Buffer.from(recordData, 'base64');
        const decodedMetrics: string[] = decodedData
          .toString('utf-8')
          .split('\n');
        const transformedMetricData = transformJsonMetricEvent(decodedMetrics);
        const metricEncodedString = Buffer.from(
          JSON.stringify(transformedMetricData),
          'utf-8'
        ).toString('base64');

        const eventMap = cloneDeep(record);
        eventMap.data = metricEncodedString;
        eventMap.result = 'Ok';
        metrics.push(eventMap);
      });
    } else {
      logger.error({
        eventCode: 'MLP2001',
        err: 'Invalid METRICS_OUTPUT_FORMAT value. Set to json',
      });
      throw new Error('Invalid METRICS_OUTPUT_FORMAT value. Set to json');
    }
    return { records: metrics };
  } catch (err) {
    logger.error({
      eventCode: 'MLP2002',
      err: 'Failed to deliver to firehose stream',
    });
    throw new Error(`Failed to deliver to firehose stream:: ${err}`);
  }
}
