terraform {
  cloud {
    organization = "170"
    workspaces {
      name = "Terraform_Working_Directory"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.33.0"
    }
  }
  required_version = ">= 1.2"
}

