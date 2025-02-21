locals {
  s3_backup_failures = file("${path.module}/rules/reporting/s3_backup_failures.tf")
  completed_batch_report_executions_aborted = file("${path.module}/rules/reporting/completed_batch_report_executions_aborted.tf")
  completed_batch_report_executions_failed = file("${path.module}/rules/reporting/completed_batch_report_executions_failed.tf")
  completed_batch_report_executions_timed_out = file("${path.module}/rules/reporting/completed_batch_report_executions_timed_out.tf")
}
