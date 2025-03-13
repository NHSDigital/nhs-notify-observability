resource "grafana_folder" "current" {
  title = "${local.csi}"
  uid   = "${local.csi}"
}
