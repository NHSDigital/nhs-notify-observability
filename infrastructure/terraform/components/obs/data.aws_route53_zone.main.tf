data "aws_route53_zone" "main" {
  name = "observe.${var.root_domain_name}"
}
