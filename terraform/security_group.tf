resource "aws_security_group" "ec2-sg" {
  vpc_id = aws_vpc.aws-dev.id
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    description = "HTTPS from IPv4 + IPv6"
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["172.27.10.0/27"]
    description = "Allows only CIDR block IPs"
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.aws-dev.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.aws-dev.cidr_block]
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}