provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.10.10.0/25"
  assign_generated_ipv6_cidr_block = true # Requests /56 from Amazon

   tags = {
    Name = "main.vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.10.10.64/27"
  ipv6_cidr_block = cidrsubnet(aws_vpc.dev_vpc.ipv6_cidr_bloc, 8, 1)
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.10.10.96/27"
  ipv6_cidr_block = cidrsubnet(aws_vpc.dev_vpc.ipv6_cidr_block, 8, 2)
  availability_zone = "eu-west-2b"
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_internet_gateway" "dual_stack_igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name = "vpc_ipv4_igw"
  } 
}
resource "aws_route_table" "dual_stack_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0" #all routes to through the gateway
    gateway_id = aws_internet_gateway.dual_stack_igw.id
  }
  route {
    ipv6_cidr_block = "::/0" #all routes to through the gateway
    gateway_id = aws_internet_gateway.dual_stack_igw.id
  }
  tags = {
    Name = "public dual stack route table"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.dual_stack_route_table.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.dual_stack_route_table.id
}

# resource "aws_route_table" "subnet1_route_table" {
#   vpc_id = aws_vpc.dev_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = {
#     Name = "Subnet 1 route table"
#   }
# }
# resource "aws_egress_only_internet_gateway" "ipv6_igw" {
#   vpc_id = aws_vpc.dev_vpc.id
#   tags = {
#     Name = "vpc_ipv6_igw"
#   }
# }