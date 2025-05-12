resource "aws_ssm_parameter" "splunk_hec_token" {
  name        = "/splunk/hec/token/${var.type}"
  type        = "SecureString"
  value       = "REPLACE_ME"
  description = "Splunk HEC token for ${var.type}"

  lifecycle {
    ignore_changes = [value]
  }
}
