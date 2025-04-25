resource "grafana_folder" "dashboards" {
  for_each = tomap({ for dir in distinct([for d in fileset("${path.module}/dashboards", "*/**/") : dirname(d)]) : dir => dir })

  title = each.key
  uid   = replace(each.key, "/", "_")
}
