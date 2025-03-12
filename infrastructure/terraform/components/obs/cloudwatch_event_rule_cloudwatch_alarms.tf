resource "aws_cloudwatch_event_rule" "cloudwatch_alarms" {
  name          = "${local.csi}-cloudwatch-alarm-forwarding"
  event_bus_name = data.terraform_remote_state.acct.outputs.event_bus_name
  description   = "Triggers Lambda when an alarm event is received"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"],
    "detail-type" = ["CloudWatch Alarm State Change"]
  })
}
