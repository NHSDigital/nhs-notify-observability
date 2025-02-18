module "lambda_grafana_alerts_teams" {
  source = "git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/lambda?ref=v1.0.9"

  function_name = "grafana-alerts-teams"
  description   = "A function for formatting and sending Grafana alerts to Teams"

  aws_account_id = var.aws_account_id
  component      = var.component
  environment    = var.environment
  project        = var.project
  region         = var.region
  group          = var.group

  log_retention_in_days = var.log_retention_in_days
  kms_key_arn           = module.kms.key_arn

  iam_policy_document = {
    body = data.aws_iam_policy_document.lambda_grafana_alerts_teams.json
  }

  function_s3_bucket      = local.acct.s3_buckets["lambda_function_artefacts"]["id"]
  function_code_base_path = local.aws_lambda_functions_dir_path
  function_code_dir       = "grafana-alerts-teams/src"
  function_include_common = true
  function_module_name    = "index"
  handler_function_name   = "handler"
  runtime                 = "nodejs20.x"
  memory                  = 128
  timeout                 = 5
  log_level               = var.log_level
  lambda_at_edge          = true

  force_lambda_code_deploy = var.force_lambda_code_deploy
  enable_lambda_insights   = false

  lambda_env_vars = {
    "TEAMS_WEBHOOK_ALERTS_SSM_PARAM" = local.acct.teams_webhook_url_alerts["name"]
  }
}

data "aws_iam_policy_document" "lambda_grafana_alerts_teams" {
  statement {
    sid    = "KMSPermissions"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [
      module.kms.key_arn,
    ]
  }

  statement {
    sid    = "SNSPermissions"
    effect = "Allow"

    actions = [
      "sns:Publish",
      "sns:Subscribe",
      "sns:Receive",
    ]

    resources = [
      aws_sns_topic.alerting.arn,
    ]
  }

  statement {
    sid    = "SSMParameterAccess"
    effect = "Allow"

    actions = [
      "ssm:GetParameter"
    ]

    resources = [
      local.acct.teams_webhook_url_alerts["arn"]
    ]
  }
}
