resource "aws_ssm_parameter" "splunk_hec_token_logs" {
  name        = "/splunk/hec/token/logs"
  type        = "SecureString"
  value       = "REPLACE_ME"
  description = "Splunk HEC token for logs"

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "splunk_hec_token_logs" {
  name       = "/splunk/hec/token/logs"
  depends_on = [ aws_ssm_parameter.splunk_hec_token_logs ]
}
