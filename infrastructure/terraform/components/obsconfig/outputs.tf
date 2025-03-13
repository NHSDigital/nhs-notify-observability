output "domain_dashboard" {
  value = {
    for key, dashboard in grafana_dashboard.domain : key => dashboard.url
  }
}
