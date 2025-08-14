module "lambda_alert_forwarding" {
  source = "git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/lambda?ref=v2.0.6"

  function_name = "alert-forwarding"
  description   = "A function for formatting and sending Cloudwatch alerts to Teams"

  aws_account_id = var.aws_account_id
  component      = var.component
  environment    = var.environment
  project        = var.project
  region         = var.region
  group          = var.group

  log_retention_in_days = var.log_retention_in_days
  kms_key_arn           = module.kms_logs.key_arn

  iam_policy_document = {
    body = data.aws_iam_policy_document.lambda_alert_forwarding.json
  }

  function_s3_bucket      = local.acct.s3_buckets["lambda_function_artefacts"]["id"]
  function_code_base_path = local.aws_lambda_functions_dir_path
  function_code_dir       = "alert-forwarding/src"
  function_include_common = true
  function_module_name    = "index"
  handler_function_name   = "handler"
  runtime                 = "nodejs22.x"
  memory                  = 128
  timeout                 = 5
  log_level               = var.log_level
  lambda_at_edge          = true

  force_lambda_code_deploy = var.force_lambda_code_deploy
  enable_lambda_insights   = false

  lambda_env_vars = {
    "TEAMS_WEBHOOK_CLOUDWATCH_SSM_PARAM"           = aws_ssm_parameter.teams_webhook_url_cloudwatch_alarms.name,
    "TEAMS_WEBHOOK_ALERTS_BACKUP_ERRORS_SSM_PARAM" = aws_ssm_parameter.teams_webhook_url_alerts_backup_errors.name
    "TEAMS_WEBHOOK_ALERTS_SECURITY_SSM_PARAM"      = aws_ssm_parameter.teams_webhook_url_alerts_security.name
  }
}

data "aws_iam_policy_document" "lambda_alert_forwarding" {
  statement {
    sid    = "KMSPermissions"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [
      module.kms_logs.key_arn,
    ]
  }

  statement {
    sid    = "SSMParameterAccess"
    effect = "Allow"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      aws_ssm_parameter.teams_webhook_url_cloudwatch_alarms.arn,
      aws_ssm_parameter.teams_webhook_url_alerts_backup_errors.arn,
      aws_ssm_parameter.teams_webhook_url_alerts_security.arn
    ]
  }
}
