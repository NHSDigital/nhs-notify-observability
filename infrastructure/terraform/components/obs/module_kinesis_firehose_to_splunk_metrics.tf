module "kinesis_firehose_to_splunk_metrics" {
  source = "../../modules/kinesis-firehose-to-splunk"

  project        = var.project
  environment    = var.environment
  aws_account_id = var.aws_account_id
  region         = var.region
  group          = var.group
  component      = var.component

  default_tags               = var.default_tags
  log_retention_in_days      = var.log_retention_in_days
  type                       = "metrics"
  kms_splunk_key_arn         = module.kms_splunk.key_arn
  splunk_firehose_bucket_arn = module.s3bucket_splunk_firehose.arn
  formatter_lambda_function_arn = module.splunk_metrics_formatter_lambda.function_arn
}
