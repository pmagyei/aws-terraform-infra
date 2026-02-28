terraform {
  cloud {
    organization = "170"
    workspaces {
      name = "learn-terraform-aws-get-started"
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

