resource "aws_grafana_role_association" "grafana" {
  role         = "ADMIN"
  group_ids    = var.delegated_grafana_admin_group_ids
  workspace_id = aws_grafana_workspace.grafana.id
}
