module "splunk_logs_formatter" {
  source = "git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/lambda?ref=v1.0.9"

  function_name = "splunk-logs-formatter"
  description   = "A function for formatting logs to send to Splunk"

  aws_account_id = var.aws_account_id
  component      = var.component
  environment    = var.environment
  project        = var.project
  region         = var.region
  group          = var.group

  log_retention_in_days = var.log_retention_in_days
  kms_key_arn           = module.kms_splunk.key_arn

  iam_policy_document = {
    body = data.aws_iam_policy_document.splunk_logs_formatter.json
  }

  function_s3_bucket      = local.acct.s3_buckets["lambda_function_artefacts"]["id"]
  function_code_base_path = local.aws_lambda_functions_dir_path
  function_code_dir       = "splunk-logs-formatter/src"
  function_include_common = true
  function_module_name    = "index"
  handler_function_name   = "kinesis-firehose-cloudwatch-logs-processor.handler"
  runtime                 = ""
  memory                  = 128
  timeout                 = 5
  log_level               = var.log_level
  lambda_at_edge          = true

  force_lambda_code_deploy = var.force_lambda_code_deploy
  enable_lambda_insights   = false
}

data "aws_iam_policy_document" "splunk_logs_formatter" {
  statement {
    sid    = "KMSPermissions"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [
      module.kms_splunk.key_arn,
    ]
  }
}
