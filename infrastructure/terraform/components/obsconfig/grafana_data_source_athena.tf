resource "grafana_data_source" "athena_deployments" {
  type = "grafana-athena-datasource"
  name = "${local.csi}-athena-deployments"

  json_data_encoded = jsonencode({
    defaultRegion  = "eu-west-2"
    authType       = "ec2_iam_role"
    catalog        = "AwsDataCatalog"
    database       = local.acct.glue_database_name
    workgroup      = local.acct.athena_workgroup["name"]
    outputLocation = local.acct.athena_workgroup["output_location"]
  })
}
