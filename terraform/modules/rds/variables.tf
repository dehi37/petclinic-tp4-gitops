variable "name_prefix" { type = string }
variable "db_subnet_ids" { type = list(string) }
variable "sg_rds_id" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "db_instance_class" { type = string }
variable "db_allocated_storage" { type = number }
variable "db_engine_version" { type = string }

variable "enable_deletion_protection" {
  description = "Activer la protection contre la suppression de la base de données"
  type        = bool
  default     = false # Désactivé par défaut (Dev), activable en Prod
}

variable "enable_performance_insights" {
  description = "Activer Performance Insights pour RDS"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "ARN de la clé KMS pour le chiffrement. Si nul, utilise les clés par défaut."
  type        = string
  default     = null
}