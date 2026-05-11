variable "aws_ami_image" {
  description = "The AWS AMI to use"
  type        = string
  default     = "ami-0d114020bf27f27cf"
}

variable "aws_instance_type" {
  description = "The AWS instance type to use"
  type        = string
  default     = "t3.micro"
}