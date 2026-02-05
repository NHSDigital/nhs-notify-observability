resource "aws_iam_role" "metric_stream_to_firehose" {
  count              = var.ship_metrics_to_splunk ? 1 : 0
  name               = "${local.csi}-metric-stream-to-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.metric_stream_to_firehose_assume_role_policy[0].json
}

data "aws_iam_policy_document" "metric_stream_to_firehose_assume_role_policy" {
  count = var.ship_metrics_to_splunk ? 1 : 0
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
  count  = var.ship_metrics_to_splunk ? 1 : 0
  name   = "${local.csi}-metric-stream-to-firehose-policy"
  policy = data.aws_iam_policy_document.metric_stream_to_firehose_policy[0].json
}

data "aws_iam_policy_document" "metric_stream_to_firehose_policy" {
  count = var.ship_metrics_to_splunk ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [
      module.kinesis_firehose_to_splunk_metrics[0].kinesis_firehose_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "metric_stream_to_firehose_attachment" {
  count      = var.ship_metrics_to_splunk ? 1 : 0
  role       = aws_iam_role.metric_stream_to_firehose[0].name
  policy_arn = aws_iam_policy.metric_stream_to_firehose_policy[0].arn
}
