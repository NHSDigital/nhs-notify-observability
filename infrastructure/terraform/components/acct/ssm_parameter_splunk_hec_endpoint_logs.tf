resource "aws_ssm_parameter" "splunk_hec_endpoint_logs" {
  name        = "/splunk/hec/endpoint/logs"
  type        = "String"
  value       = "REPLACE_ME"
  description = "Splunk HEC endpoint for logs"

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "splunk_hec_endpoint_logs" {
  name       = "/splunk/hec/endpoint/logs"
  depends_on = [ aws_ssm_parameter.splunk_hec_endpoint_logs ]
}
