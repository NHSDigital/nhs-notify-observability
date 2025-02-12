resource "grafana_folder" "current" {
  title = "${local.csi}-current-acct"
  uid   = "${local.csi}-current-acct"
}
