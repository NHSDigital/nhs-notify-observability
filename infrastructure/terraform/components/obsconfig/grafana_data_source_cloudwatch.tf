resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = "${local.csi}-cloudwatch"

  json_data_encoded = jsonencode({
    defaultRegion = "eu-west-2"
    authType      = "ec2_iam_role"
  })
}
