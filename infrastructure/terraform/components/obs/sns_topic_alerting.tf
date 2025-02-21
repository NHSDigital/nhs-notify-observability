#tfsec:ignore:aws-sns-topic-encryption-use-cmk
resource "aws_sns_topic" "main" {
  name              = "${local.csi}-alerting-topic"
  kms_master_key_id = "alias/aws/sns"
}
