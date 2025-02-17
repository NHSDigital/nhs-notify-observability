resource "aws_grafana_workspace" "obs" {
  name        = "${local.csi}-grafana-workspace"
  description = "Grafana Workspace for Observability"

  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "CUSTOMER_MANAGED"
  role_arn                 = aws_iam_role.grafana_workspace.arn

  data_sources    = ["CLOUDWATCH", "XRAY"]
  grafana_version = "10.4"

  configuration = jsonencode(
    {
      "plugins" = {
        "pluginAdminEnabled" = true
      },
      "unifiedAlerting" = {
        "enabled" = true
      }
    }
  )
}

resource "aws_ssm_parameter" "grafana_workspace_id" {

  name        = "${local.csi}-grafana-workspace-id"
  description = "Workspace ID for Grafana"

  type  = "SecureString"
  value = aws_grafana_workspace.obs.id
}
