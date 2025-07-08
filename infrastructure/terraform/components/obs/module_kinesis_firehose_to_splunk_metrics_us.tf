module "kinesis_firehose_to_splunk_metrics_us" {
  source = "../../modules/kinesis-firehose-to-splunk"

  providers = {
    aws = aws.us-east-1
  }

  project        = var.project
  environment    = var.environment
  aws_account_id = var.aws_account_id
  region         = "us-east-1"
  group          = var.group
  component      = var.component

  default_tags               = var.default_tags
  log_retention_in_days      = var.log_retention_in_days
  type                       = "metrics"
  region_prefix              = "us"
  kms_splunk_key_arn         = module.kms_splunk.replica_key_arn
  splunk_firehose_bucket_arn = module.s3bucket_splunk_firehose_us.arn
  formatter_lambda_function_arn = module.splunk_metrics_formatter_lambda_us.function_arn
}
