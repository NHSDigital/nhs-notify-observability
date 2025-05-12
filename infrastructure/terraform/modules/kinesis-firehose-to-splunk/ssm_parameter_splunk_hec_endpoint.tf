resource "aws_ssm_parameter" "splunk_hec_endpoint" {
  name        = "/splunk/hec/endpoint/${var.type}"
  type        = "String"
  value       = "REPLACE_ME"
  description = "Splunk HEC endpoint for ${var.type}"

  lifecycle {
    ignore_changes = [value]
  }
}
