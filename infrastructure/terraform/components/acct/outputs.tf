output "dns_zone" {
  value = {
    id          = aws_route53_zone.main.id
    name        = aws_route53_zone.main.name
    nameservers = aws_route53_zone.main.name_servers
  }
}

output "s3_buckets" {
  value = {
    lambda_function_artefacts = {
      arn    = module.s3bucket_lambda_artefacts.arn
      bucket = module.s3bucket_lambda_artefacts.bucket
      id     = module.s3bucket_lambda_artefacts.id
    }
  }
}

output "teams_webhook_url_alerts_name" {
  value = aws_ssm_parameter.teams_webhook_url_alerts.name
  description = "The name of the SSM Parameter for the Teams Webhook URL"
}
