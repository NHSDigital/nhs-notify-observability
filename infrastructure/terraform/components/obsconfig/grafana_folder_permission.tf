resource "grafana_folder_permission" "dashboards" {
  for_each = tomap({ for dir in distinct([for d in fileset("${path.module}/dashboards", "*/**/") : dirname(d)]) : dir => dir })

  folder_uid = grafana_folder.dashboards[each.key].uid
  permissions {
    role       = "Admin"
    permission = "Admin"
  }
  permissions {
    role       = "Editor"
    permission = "Edit"
  }
  permissions {
    role       = "Viewer"
    permission = "View"
  }
}
