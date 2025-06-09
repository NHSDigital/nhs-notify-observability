resource "aws_grafana_role_association" "admin" {
  role         = "ADMIN"
  group_ids    = var.delegated_grafana_admin_group_ids
  workspace_id = aws_grafana_workspace.grafana.id
}

resource "aws_grafana_role_association" "editor" {
  role         = "EDITOR"
  group_ids    = var.delegated_grafana_editor_group_ids
  workspace_id = aws_grafana_workspace.grafana.id
}

resource "aws_grafana_role_association" "viewer" {
  role         = "VIEWER"
  group_ids    = var.delegated_grafana_viewer_group_ids
  workspace_id = aws_grafana_workspace.grafana.id
}
