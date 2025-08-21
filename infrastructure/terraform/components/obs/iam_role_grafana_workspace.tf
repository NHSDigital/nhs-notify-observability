resource "aws_iam_role" "grafana_workspace" {
  name               = "${local.csi}-workspace-role"
  assume_role_policy = data.aws_iam_policy_document.grafana_assume_role_policy.json
}

data "aws_iam_policy_document" "grafana_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["grafana.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "grafana_workspace_cloudwatch" {
  role       = aws_iam_role.grafana_workspace.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonGrafanaCloudWatchAccess"
}

resource "aws_iam_role_policy_attachment" "grafana_workspace_athena" {
  role       = aws_iam_role.grafana_workspace.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonGrafanaAthenaAccess"
}

resource "aws_iam_role_policy_attachment" "grafana_workspace_xray" {
  role       = aws_iam_role.grafana_workspace.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
}

data "aws_iam_policy_document" "grafana_cross_account_access" {
  dynamic "statement" {
    for_each = { for bc in var.bounded_context_account_ids : bc.domain => bc if bc.override_project_name == "" }
    content {
      sid = replace("AssumeRoleCrossAccountfor${statement.value.domain}", "-", "")

      actions = [
        "sts:AssumeRole"
      ]

      resources = [
        "arn:aws:iam::${statement.value.account_id}:role/${local.csi}-cross-access-role",
      ]
    }

  }

  dynamic "statement" {
    for_each = { for bc in var.bounded_context_account_ids : bc.domain => bc if bc.override_project_name != "" }
    content {
      sid = replace("AssumeRoleCrossAccountfor${statement.value.domain}", "-", "")

      actions = [
        "sts:AssumeRole"
      ]

      resources = [
        "arn:aws:iam::${statement.value.account_id}:role/${replace(local.csi, "nhs", "nhs-notify")}-cross-access-role",
      ]
    }
  }
  statement {
    sid     = "AllowAthenaWorkspaceAccess"
    effect  = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:CreateBucket",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutObject",
    ]

    resources = [
      "${local.acct.s3_buckets["observability"]["arn"]}/athena-output/*"
    ]
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
