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

variable "interface_endpoint_services" {
  type = map(string)
  default = {
    ec2messages = "com.amazonaws.eu-west-2.ec2messages"
    ssmmessages = "com.amazonaws.eu-west-2.ssmmessages"
    ssm         = "com.amazonaws.eu-west-2.ssm"
    cw          = "com.amazonaws.eu-west-2.monitoring"
    logs        = "com.amazonaws.eu-west-2.logs"
    ec2         = "com.amazonaws.eu-west-2.ec2"
  }
}
