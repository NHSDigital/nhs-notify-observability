# As this is just a proxy for the Managed Grafana we're skipping WAF and Logging
#trivy:ignore:aws-cloudfront-enable-waf
#trivy:ignore:aws-cloudfront-enable-logging
resource "aws_cloudfront_distribution" "main" {
  provider = aws.us-east-1

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "NHS Notify Grafana proxy (${local.csi})"
  default_root_object = ""
  price_class         = "PriceClass_100" # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cloudfront-distribution-distributionconfig.html#cfn-cloudfront-distribution-distributionconfig-priceclass

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB"]
    }
  }

  aliases = [local.root_domain_name]

  viewer_certificate {
    cloudfront_default_certificate = true
    # Uncomment below after we get DNS validation working when we cutover DNS
    # acm_certificate_arn            = aws_acm_certificate.main.arn
    # minimum_protocol_version       = "TLSv1.2_2021" # Supports 1.2 & 1.3 - https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html
    # ssl_support_method             = "sni-only"
  }

  origin {
    domain_name = aws_grafana_workspace.grafana.endpoint
    origin_id   = "GrafanaOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "GrafanaOrigin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }
}
