resource "grafana_contact_point" "sns" {
  name = "${local.csi}-alerting-sns"

  sns {
    topic           = aws_sns_topic.main.arn
    assume_role_arn = aws_iam_role.sns_alert_role.arn
    message_format  = "json"
    subject         = "{{ template \"default.title\" .}}"
  }
}
