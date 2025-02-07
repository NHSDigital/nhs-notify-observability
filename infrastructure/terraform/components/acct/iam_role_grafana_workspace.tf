resource "aws_iam_role" "grafana_workspace" {
  name = "${local.csi}-grafana-workspace-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grafana_workspace_cloudwatch" {
  role       = aws_iam_role.grafana_workspace.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonGrafanaCloudWatchAccess"
}

resource "aws_iam_role_policy_attachment" "grafana_workspace_xray" {
  role       = aws_iam_role.grafana_workspace.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
}

data "aws_iam_policy_document" "grafana_cross_account_access" {
  dynamic "statement" {
    for_each = var.grafana_cross_account_ids
    content {
      sid = replace("AssumeRoleCrossAccountfor${statement.value.domain}", "-", "")

      actions = [
        "sts:AssumeRole"
      ]

      resources = [
        "arn:aws:iam::${statement.value.account_id}:role/${local.csi}-grafana-cross-access-role",
      ]
    }

  }

}

resource "aws_iam_policy" "grafana_cross_account_access" {
  name   = "${local.csi}-grafana-cross-account-role-access"
  path   = "/"
  policy = data.aws_iam_policy_document.grafana_cross_account_access.json
}

resource "aws_iam_role_policy_attachment" "grafana_workspace_cross_account" {
  role       = aws_iam_role.grafana_workspace.name
  policy_arn = aws_iam_policy.grafana_cross_account_access.arn
}
