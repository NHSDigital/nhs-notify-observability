module "splunk_metrics_formatter_lambda_us" {
  providers = {
    aws = aws.us-east-1
  }
  source = "git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/lambda?ref=v2.0.13"

  function_name = "splunk-metrics-formatter"
  description   = "A function for formatting metrics for Splunk"

  aws_account_id = var.aws_account_id
  component      = var.component
  environment    = var.environment
  project        = var.project
  region         = "us-east-1"
  group          = var.group

  log_retention_in_days = var.log_retention_in_days
  kms_key_arn           = module.kms_logs.replica_key_arn

  iam_policy_document = {
    body = data.aws_iam_policy_document.splunk_metrics_formatter_kinesis_perms.json
  }

  function_s3_bucket      = local.acct.s3_buckets["lambda_function_artefacts_us"]["id"]
  function_code_base_path = local.aws_lambda_functions_dir_path
  function_code_dir       = "metric-lambda-processor/dist"
  function_module_name    = "index"
  handler_function_name   = "handler"
  runtime                 = "nodejs22.x"
  memory                  = 512
  timeout                 = 900

  lambda_env_vars = {
    ENVIRONMENT                  = var.environment
    SPLUNK_CLOUDWATCH_SOURCETYPE = "aws:cloudwatch:metric"
    METRICS_OUTPUT_FORMAT        = "json"
  }
}

data "aws_iam_policy_document" "splunk_metrics_formatter_kinesis_perms_us" {
  provider = aws.us-east-1
  statement {
    actions = [
      "firehose:PutRecordBatch",
    ]

    resources = [
      "arn:aws:firehose:us-east-1:${var.aws_account_id}:deliverystream/${local.csi}-splunk-metrics-firehose"
    ]
  }
}
