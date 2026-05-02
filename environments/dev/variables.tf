variable "aws_ami_image" {
  description = "The AWS AMI to use"
  type        = string
  default     = "ami-09dbc7ce74870d573"
}

variable "aws_instance_type" {
  description = "The AWS instance type to use"
  type        = string
  default     = "t3.micro"
}

variable "aws_key_name" {
  description = "The name of the AWS Key Pair to use"
  type        = string
  default     = "nb-key-pair"
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "public_key" {
    type = string
    default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4P3ikoeLz6ROeFGuuH8t1bUdFpTrpPDHrucNvKGHTm dantejit@MBPDante"
}


