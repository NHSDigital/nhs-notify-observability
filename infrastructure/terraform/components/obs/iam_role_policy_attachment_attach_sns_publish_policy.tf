
resource "aws_iam_role_policy_attachment" "attach_sns_publish_policy" {
  role       = aws_iam_role.sns_alert_role.name
  policy_arn = aws_iam_policy.sns_publish.arn
}
