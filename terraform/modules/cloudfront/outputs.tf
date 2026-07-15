output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "Nom de domaine public du CDN CloudFront"
}