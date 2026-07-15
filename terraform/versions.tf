terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}


provider "aws" {
  region = var.aws_region

  # Application automatique des étiquettes (Tags requis)
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Binome      = "Binome$Dehi_Atikh"
      CostCenter  = "ISI-Dakar-TP4"
    }
  }
}
