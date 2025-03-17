data "aws_ssm_parameter" "grafana_workspace_id" {
  provider = aws.eu-west-2
  name     = replace("${local.csi}-workspace-id", var.component, "obs")
}
