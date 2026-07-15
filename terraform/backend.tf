terraform {
  backend "s3" {
    bucket         = "petclinic-isi-tfstate-dehi-atikh" # S'aligne avec le bootstrap
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "petclinic-isi-tflocks-dehi-atikh"
    encrypt        = true
  }
}