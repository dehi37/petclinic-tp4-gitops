variable "name_prefix" {
  type        = string
  description = "Prefixe utilise pour nommer les ressources"
}

variable "vpc_id" {
  type        = string
  description = "ID du VPC ou deployer les Security Groups"
}

variable "container_port" {
  type        = number
  description = "Port expose par le conteneur applicatif"
  default     = 8080
}

variable "enable_rds_egress" {
  type        = bool
  description = "Activer ou non la regle de sortie par defaut (egress) pour le RDS"
  default     = false # Desactive par defaut pour la securite (et passer tfsec !)
}