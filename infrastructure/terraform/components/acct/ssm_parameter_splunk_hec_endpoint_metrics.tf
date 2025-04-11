resource "aws_ssm_parameter" "splunk_hec_endpoint_metrics" {
  name        = "/splunk/hec/endpoint/metrics"
  type        = "String"
  value       = "REPLACE_ME"
  description = "Splunk HEC endpoint for metrics"

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "splunk_hec_endpoint_metrics" {
  name       = "/splunk/hec/endpoint/metrics"
  depends_on = [ aws_ssm_parameter.splunk_hec_endpoint_metrics ]

}
