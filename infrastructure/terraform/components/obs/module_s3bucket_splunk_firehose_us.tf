module "s3bucket_splunk_firehose_us" {
  source = "https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.20/terraform-s3bucket.zip"
  providers = {
    aws = aws.us-east-1
  }

  name = "splunk-firehose-us"

  aws_account_id = var.aws_account_id
  region         = "us-east-1"
  project        = var.project
  environment    = var.environment
  component      = var.component

  acl           = "private"
  force_destroy = false
  versioning    = true

  kms_key_arn = module.kms_splunk.replica_key_arn

  lifecycle_rules = [
    {
      prefix  = ""
      enabled = true

      noncurrent_version_transition = [
        {
          noncurrent_days = "30"
          storage_class   = "STANDARD_IA"
        }
      ]

      noncurrent_version_expiration = {
        noncurrent_days = "90"
      }

      abort_incomplete_multipart_upload = {
        days = "1"
      }
    }
  ]

  policy_documents = [
    data.aws_iam_policy_document.s3bucket_splunk_firehose_us.json
  ]

  bucket_logging_target = {
    bucket = local.acct.s3_buckets["access_logs_us"]["id"]
  }

  public_access = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  default_tags = {
    Name = "Splunk Firehose Bucket"
  }
}

data "aws_iam_policy_document" "s3bucket_splunk_firehose_us" {
  statement {
    sid    = "DontAllowNonSecureConnection"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      module.s3bucket_splunk_firehose_us.arn,
      "${module.s3bucket_splunk_firehose_us.arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "*",
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }

  statement {
    sid    = "AllowManagedAccountsToList"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      module.s3bucket_splunk_firehose_us.arn,
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root"
      ]
    }
  }

  statement {
    sid    = "AllowManagedAccountsToGet"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${module.s3bucket_splunk_firehose_us.arn}/*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.aws_account_id}:root"
      ]
    }
  }
}
