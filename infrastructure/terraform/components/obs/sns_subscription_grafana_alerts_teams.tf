resource "aws_sns_topic_subscription" "lambda_grafana_alerts_teams" {
  topic_arn = aws_sns_topic.alerting.arn
  protocol  = "lambda"
  endpoint  = module.lambda_grafana_alerts_teams.function_arn
}
