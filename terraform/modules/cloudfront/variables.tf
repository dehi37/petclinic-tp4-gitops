variable "name_prefix" {
  type        = string
  description = "Préfixe pour nommer les ressources associées à CloudFront"
}

variable "alb_dns_name" {
  type        = string
  description = "Le nom de domaine DNS de l'Application Load Balancer"
}
variable "waf_web_acl_arn" {
  description = "ARN du WAF Web ACL. Si nul, aucun WAF n'est associé."
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ARN du certificat ACM. Si nul, utilise le certificat CloudFront par défaut."
  type        = string
  default     = null
}

variable "enable_logging" {
  description = "Activer ou désactiver les logs d'accès CloudFront"
  type        = bool
  default     = false
}

variable "log_bucket_domain_name" {
  description = "Nom de domaine du bucket S3 pour les logs"
  type        = string
  default     = null
}