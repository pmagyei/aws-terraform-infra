variable "aws_ami_image" {
  description = "The AWS AMI to use"
  type        = string
  default     = "ami-0c895b0fc853621e9"

}

variable "aws_instance_type" {
  description = "The AWS instance type to use"
  type        = string
  default     = "t3.micro"
}


