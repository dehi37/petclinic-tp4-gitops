variable "name_prefix" {
  description = "Préfixe pour nommer les ressources"
  type        = string
}

variable "alb_dns_name" {
  description = "Nom de domaine DNS DNS public de l'ALB"
  type        = string
}