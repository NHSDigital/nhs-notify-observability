resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = "${local.csi}-cloudwatch"

  json_data_encoded = jsonencode({
    defaultRegion = "eu-west-2"
    authType      = "ec2_iam_role"
  })
}

resource "grafana_data_source" "cloudwatch_cross_account" {
  for_each = { for id, account_config in var.delegated_grafana_account_ids : account_config.domain => account_config }
  type     = "cloudwatch"
  name     = "${local.csi}-cloudwatch-${each.value.domain}"

  json_data_encoded = jsonencode({
    defaultRegion = "eu-west-2"
    authType      = "ec2_iam_role"
    assumeRoleArn = replace("arn:aws:iam::${each.value.account_id}:role/${local.csi}-grafana-cross-access-role", var.component, "acct")
  })
}
