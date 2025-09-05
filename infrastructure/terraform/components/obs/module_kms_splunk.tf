module "kms_splunk" {
  source = "https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.20/terraform-kms.zip"
  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  aws_account_id = var.aws_account_id
  component      = var.component
  environment    = var.environment
  project        = var.project
  region         = var.region

  name                 = "${local.csi}-splunk-logs"
  deletion_window      = var.kms_deletion_window
  alias                = "alias/${local.csi}-splunk"
  key_policy_documents = [data.aws_iam_policy_document.kms_splunk.json]
  iam_delegation       = true
  is_multi_region      = true
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
        module.s3bucket_splunk_firehose.arn,
        "${module.s3bucket_splunk_firehose.arn}/*",
      ]
    }
  }

  statement {
    sid    = "AllowCloudWatchLogsEncrypt"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "logs.${var.region}.amazonaws.com",
        "logs.us-east-1.amazonaws.com", # For multi-region keys
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:${local.csi}-splunk-logs-firehose",
        "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:${local.csi}-splunk-metrics-firehose",
        "arn:aws:logs:us-east-1:${var.aws_account_id}:log-group:${local.csi}-splunk-metrics-firehose"
      ]
    }
  }
}
