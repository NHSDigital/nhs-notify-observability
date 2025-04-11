resource "aws_iam_role" "metric_stream_to_firehose" {
  name               = "${local.csi}-metric-stream-to-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.metric_stream_to_firehose_assume_role_policy.json
}

data "aws_iam_policy_document" "metric_stream_to_firehose_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["streams.metrics.cloudwatch.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "metric_stream_to_firehose_policy" {
  name   = "${local.csi}-metric-stream-to-firehose-policy"
  policy = data.aws_iam_policy_document.metric_stream_to_firehose_policy.json
}

data "aws_iam_policy_document" "metric_stream_to_firehose_policy" {
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.splunk_metrics.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "metric_stream_to_firehose_attachment" {
  role       = aws_iam_role.metric_stream_to_firehose.name
  policy_arn = aws_iam_policy.metric_stream_to_firehose_policy.arn
}
