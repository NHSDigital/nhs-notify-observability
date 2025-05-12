resource "aws_ssm_parameter" "splunk_hec_endpoint" {
  name        = "/splunk/hec/endpoint/${var.type}"
  type        = "String"
  value       = "https://firehose.inputs.splunk.aws.digital.nhs.uk"
  description = "Splunk HEC endpoint for ${var.type}"

  lifecycle {
    ignore_changes = [value]
  }
}
