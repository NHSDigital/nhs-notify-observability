resource "aws_cloudwatch_event_rule" "main" {
  name          = "${local.csi}-cloudwatch-alarm-forwarding"
  event_bus_name = aws_cloudwatch_event_bus.main.name
  description   = "Triggers Lambda when an alarm event is received"

  event_pattern = jsonencode({
    source      = ["aws.cloudwatch"],
    "detail-type" = ["CloudWatch Alarm State Change"]
  })
}
