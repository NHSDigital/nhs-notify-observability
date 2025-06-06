export type recordEntry = {
  result: string;
  recordId: string;
  approximateArrivalTimestamp: string;
  data: string;
};

export type metricEventType = {
  invocationId: string;
  deliveryStreamArn: string;
  region: string;
  records: recordEntry[];
};
