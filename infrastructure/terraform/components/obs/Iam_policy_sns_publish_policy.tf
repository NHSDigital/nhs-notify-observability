resource "aws_iam_policy" "sns_publish" {
  name        = "${local.csi}-SNSPublishPolicy"
  description = "Allows publishing alerts to an SNS topic"
  policy      = data.aws_iam_policy_document.sns_publish.json
}
