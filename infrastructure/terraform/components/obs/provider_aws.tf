provider "aws" {
  alias  = "eu-west-2"
  region = var.region

  allowed_account_ids = [
    var.aws_account_id,
  ]

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = local.default_tags
  }

  allowed_account_ids = [
    var.aws_account_id,
  ]
}

provider "grafana" {
  url  = "https://${data.aws_ssm_parameter.grafana_workspace_id.value}.grafana-workspace.${var.region}.amazonaws.com"
  auth = var.service_account_token
}
