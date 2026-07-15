variable "name_prefix" {
  description = "Préfixe pour nommer les ressources"
  type        = string
}

variable "alb_arn" {
  description = "L'ARN de l'Application Load Balancer à protéger"
  type        = string
}