resource "grafana_dashboard" "current" {
  folder = grafana_folder.current.uid

  config_json = templatefile("${path.module}/templates/local-dashboard.json.tmpl", {
    current_account_id         = var.aws_account_id
    cloudwatch_data_source_uid = grafana_data_source.cloudwatch.uid
  })

}
