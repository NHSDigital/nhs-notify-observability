output "domain_dashboard" {
  value = {
    url          = { for k,v in grafana_dashboard.domain : k => v.url }
  }
}
