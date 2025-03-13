locals {
  domain_templates = {
    for account_config in var.delegated_grafana_account_ids : account_config.domain => fileset("${path.module}/templates/${account_config.domain}", "*.json.tmpl")
  }
}

resource "grafana_dashboard" "domain" {
  for_each = {
    for entry in flatten([
      for domain, templates in local.domain_templates : [
        for template in templates : {
          key       = replace("${domain}-${template}", ".json.tmpl", "" )
          domain    = domain
          template  = template
          account_id = [for acc in var.delegated_grafana_account_ids : acc.account_id if acc.domain == domain][0]
          folder_uid = grafana_folder.domain[domain].uid
          datasource = grafana_data_source.cloudwatch_cross_account[domain].uid
          environment = var.environment
        }
      ]
    ]) : entry.key => entry
  }

  folder = each.value.folder_uid

  config_json = templatefile("${path.module}/templates/${each.value.domain}/${each.value.template}", {
    account_id                 = each.value.account_id
    cloudwatch_data_source_uid = each.value.datasource
    environment                = each.value.environment
  })
}
