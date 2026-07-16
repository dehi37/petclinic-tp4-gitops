resource "aws_cloudfront_distribution" "this" {
  # 1. Argument obligatoire : Activer la distribution
  enabled = true

  # 2. Bloc Obligatoire : Origin (Pointe vers ton ALB de manière dynamique)
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "ALB-Origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # Redirige en HTTP simple vers l'ALB
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Optionnel : Association WAF dynamique
  web_acl_id = var.waf_web_acl_arn

  # Comportement par défaut (Redirection HTTP vers HTTPS automatique)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-Origin"

    # Correctif de sécurité majeur : Force le HTTPS
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # 3. Bloc Obligatoire : Restrictions (Ici, aucune restriction géographique)
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # TLS et certificat dynamiques
  viewer_certificate {
    cloudfront_default_certificate = var.certificate_arn == null ? true : false
    acm_certificate_arn            = var.certificate_arn
    ssl_support_method             = var.certificate_arn != null ? "sni-only" : null
    minimum_protocol_version       = var.certificate_arn != null ? "TLSv1.2_2021" : "TLSv1"
  }

  # Logging optionnel et dynamique
  dynamic "logging_config" {
    for_each = var.enable_logging && var.log_bucket_domain_name != null ? [1] : []
    content {
      include_cookies = false
      bucket          = var.log_bucket_domain_name
      prefix          = "cloudfront/"
    }
  }
}