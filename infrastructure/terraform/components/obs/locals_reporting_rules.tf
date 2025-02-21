locals {
  reporting_rule_files = [
    "s3_backup_failures",
    "completed_batch_report_executions_aborted",
    "completed_batch_report_executions_failed",
    "completed_batch_report_executions_timed_out"
  ]
}
