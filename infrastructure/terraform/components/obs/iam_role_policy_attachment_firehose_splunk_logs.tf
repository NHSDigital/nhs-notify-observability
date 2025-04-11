resource "aws_iam_role_policy_attachment" "firehose_splunk_logs" {
  role       = aws_iam_role.firehose_splunk_logs.name
  policy_arn = aws_iam_policy.firehose_splunk_logs.arn
}
