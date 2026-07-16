resource "aws_cloudfront_distribution" "this" {
  # ... (origins)

  # Fix #9: Link your Web ACL ARN
  web_acl_id = var.waf_web_acl_arn

  # Fix #10: Specify a secure, modern TLS version (Avoid default CloudFront certificate if production)
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021" # Uses modern secure TLS
  }

  # Fix #21: Enable Logging
  logging_config {
    include_cookies = false
    bucket          = var.log_bucket_domain_name
    prefix          = "cloudfront/"
  }
}