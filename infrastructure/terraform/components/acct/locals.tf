locals {
  root_domain_name = "${var.environment}.${aws_route53_zone.main.name}" # e.g. [main|dev|abxy0].observe.[dev|nonprod|prod].nhsnotify.national.nhs.uk
}
