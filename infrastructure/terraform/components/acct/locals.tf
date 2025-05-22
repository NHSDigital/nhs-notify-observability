locals {
  root_domain_name              = "${var.environment}.${aws_route53_zone.main.name}" # e.g. [main|dev|abxy0].observe.[dev|nonprod|prod].nhsnotify.national.nhs.uk
  aws_lambda_functions_dir_path = "../../../../lambdas"
  log_dest_regions = {
    eu_west_2 = {
      provider = null
    }
    us_east_1 = {
      provider = aws.us_east_1
    }
  }
}
