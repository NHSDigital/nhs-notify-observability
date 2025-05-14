resource "aws_ssm_parameter" "splunk_hec_token" {
  name        = "/splunk/hec/token/${var.type}"
  type        = "SecureString"
  value       = "B5A79AAD-D822-46CC-80D1-819F80D7BFB0" #dummy real-looking token to fool kinesis to create otherwise it fails with invalid HEC token message and we would need to deploy twice after fixing the token value"
  description = "Splunk HEC token for ${var.type}"

  lifecycle {
    ignore_changes = [value]
  }
}
