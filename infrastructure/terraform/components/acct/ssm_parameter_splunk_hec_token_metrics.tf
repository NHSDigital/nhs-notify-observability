resource "aws_ssm_parameter" "splunk_hec_token_metrics" {
  name        = "/splunk/hec/token/metrics"
  type        = "SecureString"
  value       = "REPLACE_ME"
  description = "Splunk HEC token for metrics"

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "splunk_hec_token_metrics" {
  name       = "/splunk/hec/token/metrics"
  depends_on = [ aws_ssm_parameter.splunk_hec_token_metrics ]
}
