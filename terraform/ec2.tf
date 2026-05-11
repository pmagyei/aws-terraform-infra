resource "aws_instance" "app_server_a" {
  ami                  = var.aws_ami_image
  instance_type        = var.aws_instance_type
  iam_instance_profile = aws_iam_instance_profile.app_server_profile.name

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    yum update -y
    yum install -y aws-cli
  EOF

  user_data_replace_on_change = true

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "app-server-a"
    managed-by  = "terraform"
    owner       = "pmagyei"
    project     = "aws-infra"
    environment = "eu-west-2"
  }
}
