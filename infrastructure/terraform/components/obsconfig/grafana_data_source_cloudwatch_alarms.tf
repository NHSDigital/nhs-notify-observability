resource "grafana_data_source" "cloudwatch_alarms" {
  type = "computest-cloudwatchalarm-datasource"
  name = "${local.csi}-cloudwatch-alarms"

  json_data_encoded = jsonencode({
    defaultRegion = "eu-west-2"
    authType      = "ec2_iam_role"
  })
}

resource "grafana_data_source" "cloudwatch_alarms_cross_account" {
  for_each = { for id, account_config in var.bounded_context_account_ids : account_config.domain => account_config }

  type = "computest-cloudwatchalarm-datasource"
  name = "CloudWatch-Alarms-${each.value.domain}"

  json_data_encoded = jsonencode({
    defaultRegion           = "eu-west-2"
    authType                = "ec2_iam_role"
    assumeRoleArn           = replace("arn:aws:iam::${each.value.account_id}:role/${local.role_name_pattern[each.value.domain]}", "-${var.component}", "")
    customMetricsNamespaces = length(each.value.custom_namespaces) > 0 ? join(",", each.value.custom_namespaces) : null
  })
}
