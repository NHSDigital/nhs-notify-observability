resource "grafana_rule_group" "reporting" {
  name             = "Reporting Alerts"
  folder_uid       = "${local.csi}-reporting"
  interval_seconds = 3600

  dynamic "rule" {
    for_each = local.reporting_rule_files
    content {
      ${templatefile("${path.module}/rules/reporting/${rule.value}", {})}
    }
  }
}
