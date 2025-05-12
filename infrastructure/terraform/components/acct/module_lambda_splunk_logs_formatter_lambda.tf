module "splunk_logs_formatter_lambda" {
  source = "git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/lambda?ref=v1.0.8"

  function_name = "splunk-logs-formatter"
  description   = "A function for formatting logs for Splunk"

  aws_account_id = var.aws_account_id
  component      = var.component
  environment    = var.environment
  project        = var.project
  region         = var.region
  group          = var.group

  log_retention_in_days = var.log_retention_in_days
  kms_key_arn           = module.kms_splunk.key_arn

  iam_policy_document = {
    body = data.aws_iam_policy_document.splunk_formatter_kinesis_perms.json
  }

  function_s3_bucket      = module.s3bucket_lambda_artefacts.id
  function_code_base_path = local.aws_lambda_functions_dir_path
  function_code_dir       = "firehose-to-splunk-formatter-logs"
  function_module_name    = "index"
  handler_function_name   = "kinesis-firehose-cloudwatch-logs-processor.handler"
  runtime                 = "python3.12"
  memory                  = 128
  timeout                 = 900

  lambda_env_vars = {
    ENVIRONMENT = var.environment
  }
}

data "aws_iam_policy_document" "splunk_formatter_kinesis_perms" {
  statement {
    actions = [
      "firehose:PutRecordBatch",
    ]

    resources = [
      "arn:aws:firehose:${var.region}:${var.aws_account_id}:deliverystream/${local.csi}-splunk-logs-firehose"
    ]
  }
}