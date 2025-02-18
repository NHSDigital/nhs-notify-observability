resource "aws_route53_record" "grafana" {
  name    = local.root_domain_name
  zone_id = aws_route53_zone.main.id
  type    = "CNAME"
  ttl     = 5
  records = [aws_cloudfront_distribution.main.domain_name]
}
