resource "grafana_dashboard" "dashboards" {
  for_each = fileset("${path.module}/dashboards", "*/**/*.json")

  folder      = dirname(each.value)
  config_json = file("${path.module}/dashboards/${each.value}")

  depends_on = [grafana_folder.dashboards]
}
