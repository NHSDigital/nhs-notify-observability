output "dashboards" {
  value = {
    for key, dashboard in grafana_dashboard.dashboards : key => dashboard.url
  }
}
