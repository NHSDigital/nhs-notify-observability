resource "aws_cloudwatch_event_rule" "sechub" {
  name           = "${local.csi}-sechub"
  event_bus_name = data.terraform_remote_state.acct.outputs.acct_event_bus_name
  description    = "Triggers Lambda when Sechub event is received"

  event_pattern = jsonencode({
    source = ["notify.sechub"],
  })
}
