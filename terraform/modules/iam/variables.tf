variable "name_prefix" { type = string }
variable "aws_region" { type = string }
variable "db_secret_arn" { type = string }
variable "ecr_repository_arn" { type = string }
variable "log_group_arn" { type = string }

variable "github_repo" {
  type        = string
  description = "Le dépôt GitHub pour les rôles IAM"
  default     = "" # Ou null
}