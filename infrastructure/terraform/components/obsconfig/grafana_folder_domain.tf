resource "grafana_folder" "domain" {
  for_each = { for id, account_config in var.delegated_grafana_account_ids : account_config.domain => account_config }
  title    = "${local.csi}-${each.value.domain}"
  uid      = "${local.csi}-${each.value.domain}"
}
