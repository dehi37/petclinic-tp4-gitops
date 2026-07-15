variable "aws_region" {
  type        = string
  description = "Région AWS"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Nom du projet"
  default     = "petclinic-isi"
}

variable "binome_name" {
  type        = string
  description = "Identifiant unique du binôme"
  default     = "dehi-atikh" # Sans caractères spéciaux
}