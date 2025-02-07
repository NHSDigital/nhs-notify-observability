resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = "${local.csi}-current-account-cloudwatch-ds"

  json_data_encoded = jsonencode({
    defaultRegion = "eu-west-2"
    authType      = "ec2_iam_role"
  })
}

resource "grafana_data_source" "cloudwatch_cross_account" {
  for_each = { for id, account_config in var.grafana_cross_account_ids : account_config.domain => account_config }
  type     = "cloudwatch"
  name     = "${local.csi}-cross-account-cloudwatch-${each.value.domain}"

  json_data_encoded = jsonencode({
    defaultRegion = "eu-west-2"
    authType      = "ec2_iam_role"
    assumeRoleArn = replace("arn:aws:iam::${each.value.account_id}:role/${local.csi}-grafana-cross-access-role", var.component, "acct")
  })
}
