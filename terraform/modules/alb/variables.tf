variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "sg_alb_id" { type = string }
variable "container_port" { type = number }
variable "kms_key_arn" {
  description = "ARN de la clé KMS pour le chiffrement du bucket S3. Si nul, utilise AES256 (par défaut)."
  type        = string
  default     = null
}
variable "enable_s3_versioning" {
  description = "Activer ou désactiver le versioning sur le bucket de logs"
  type        = bool
  default     = false # Désactivé par défaut
}
variable "certificate_arn" {
  type    = string
  default = ""
}
variable "domain_name" {
  type    = string
  default = ""
}
