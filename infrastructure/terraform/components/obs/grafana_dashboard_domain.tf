resource "grafana_dashboard" "doamin" {
  for_each = { for id, account_config in var.grafana_cross_account_ids : account_config.domain => account_config }
  folder   = grafana_folder.domain["${each.value.domain}"].uid

  config_json = templatefile("${path.module}/templates/${each.value.domain}-dashboard.json.tmpl", {
    account_id                 = each.value.account_id
    cloudwatch_data_source_uid = grafana_data_source.cloudwatch_cross_account["${each.value.domain}"].uid
  })

}
