module "kms_splunk" {
  source = "git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/kms?ref=v1.0.9"

  aws_account_id = var.aws_account_id
  component      = var.component
  environment    = var.environment
  project        = var.project
  region         = var.region

  name                 = "${local.csi}-splunk-logs"
  deletion_window      = var.kms_deletion_window
  alias                = "alias/${local.csi_global}-splunk"
  key_policy_documents = [data.aws_iam_policy_document.kms_splunk.json]
  iam_delegation       = true
}

data "aws_iam_policy_document" "kms_splunk" {
  statement {
    sid    = "AllowS3Encrypt"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "s3.amazonaws.com",
      ]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:EncryptionContext:aws:s3:arn"

      values = [
        module.s3bucket_splunk_logs.arn,
        "${module.s3bucket_splunk_logs.arn}/*",
      ]
    }
  }
}
