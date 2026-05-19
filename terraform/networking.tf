resource "aws_vpc" "aws-dev" {
  cidr_block           = "172.27.10.0/27"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "aws-dev"
  }
}
resource "aws_subnet" "dev" {
  vpc_id     = aws_vpc.aws-dev.id
  cidr_block = aws_vpc.aws-dev.cidr_block
  tags = {
    Name = "Dev"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.interface_endpoint_services

  vpc_id              = aws_vpc.aws-dev.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.dev.id
  ]
  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]
  tags = {
    Name = "${each.key}-endpoint"
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
