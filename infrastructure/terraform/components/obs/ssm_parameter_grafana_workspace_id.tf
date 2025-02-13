data "aws_ssm_parameter" "grafana_workspace_id" {
  provider = aws.eu-west-2
  name     = replace("${local.csi}-grafana-workspace-id", var.component, "acct")
}
