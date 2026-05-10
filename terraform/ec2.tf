resource "aws_instance" "name" {
    ami = 
    instance_type = 
    iam_instance_profile = aws_iam_instance_profile.ec2-iam
    user_data = #installs amazon-cloudwatch-agent. and start it with a basic configuration file mapping memory usage and /var/log/messages
  
}