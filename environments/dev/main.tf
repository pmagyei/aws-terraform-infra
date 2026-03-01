provider "aws" {
  region = "eu-west-2"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"


  name = "dev_vpc"
  cidr = "10.10.10.0/25"

  azs             = ["eu-west-2a"]
  private_subnets = ["10.10.10.0/27", "10.10.10.32/27"]
  public_subnets  = ["10.10.10.64/27", "10.10.10.96/27"]

  enable_nat_gateway   = true
  single_nat_gateway = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

