module "splunk_metrics_formatter_lambda" {
  source = "https://github.com/NHSDigital/nhs-notify-shared-modules/releases/download/v2.0.29/terraform-lambda.zip"

  function_name = "splunk-metrics-formatter"
  description   = "A function for formatting metrics for Splunk"

  aws_account_id = var.aws_account_id
  component      = var.component
  environment    = var.environment
  project        = var.project
  region         = var.region
  group          = var.group

  log_retention_in_days = var.log_retention_in_days
  kms_key_arn           = module.kms_logs.key_arn

  iam_policy_document = {
    body = data.aws_iam_policy_document.splunk_metrics_formatter_kinesis_perms.json
  }

  function_s3_bucket      = local.acct.s3_buckets["lambda_function_artefacts"]["id"]
  function_code_base_path = local.aws_lambda_functions_dir_path
  function_code_dir       = "metric-lambda-processor/dist"
  function_module_name    = "index"
  handler_function_name   = "handler"
  runtime                 = "nodejs22.x"
  memory                  = 512
  timeout                 = 900

  send_to_firehose = false

  lambda_env_vars = {
    ENVIRONMENT                  = var.environment
    SPLUNK_CLOUDWATCH_SOURCETYPE = "aws:cloudwatch:metric"
    METRICS_OUTPUT_FORMAT        = "json"
  }
}

data "aws_iam_policy_document" "splunk_metrics_formatter_kinesis_perms" {
  statement {
    actions = [
      "firehose:PutRecordBatch",
    ]

    resources = [
      "arn:aws:firehose:${var.region}:${var.aws_account_id}:deliverystream/${local.csi}-splunk-metrics-firehose"
    ]
  }
}
