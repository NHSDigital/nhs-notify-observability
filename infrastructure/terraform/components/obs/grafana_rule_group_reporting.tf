resource "grafana_rule_group" "reporting" {
  name             = "Reporting Alerts"
  folder_uid       = "${local.csi}-reporting"
  interval_seconds = 3600

  ${local.s3_backup_failures}
  ${local.completed_batch_report_executions_aborted}
  ${local.completed_batch_report_executions_failed}
  ${local.completed_batch_report_executions_timed_out}
}
