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

resource "aws_internet_gateway" "dual_stack_igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name = "vpc_igw"
  } 
}

#ipv6
resource "aws_egress_only_internet_gateway" "ipv6_igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name = "vpc_ipv6_igw"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.10.10.0/27"
  ipv6_cidr_block = cidrsubnet(aws_vpc.dev_vpc.ipv6_cidr_block, 8, 1)
  availability_zone = "eu-west-2a"
  tags = {
    Name = "public_subnet_a"
  }
}
resource "aws_subnet" "private_subnet_a" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.10.10.64/27"
  ipv6_cidr_block = cidrsubnet(aws_vpc.dev_vpc.ipv6_cidr_block, 8, 2)
  availability_zone = "eu-west-2a"
  tags = {
    Name = "private_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.10.10.32/27"
  ipv6_cidr_block = cidrsubnet(aws_vpc.dev_vpc.ipv6_cidr_block, 8, 3)
  availability_zone = "eu-west-2b"
  tags = {
    Name = "public_subnet_b"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.10.10.96/27"
  ipv6_cidr_block = cidrsubnet(aws_vpc.dev_vpc.ipv6_cidr_block, 8, 4)
  availability_zone = "eu-west-2b"
  tags = {
    Name = "private_subnet_b"
  }
}

#ipv4
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}
resource "aws_nat_gateway" "ipv4_nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_subnet_a.id 
  tags = {
    Name = "aws_nat_gw"
  }
}

resource "aws_route_table" "dual_stack_public_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0" #all routes through the gateway
    gateway_id = aws_internet_gateway.dual_stack_igw.id
  }
  route {
    ipv6_cidr_block = "::/0" #all routes through the gateway
    gateway_id = aws_internet_gateway.dual_stack_igw.id
  }
  tags = {
    Name = "public_dual_stack_rt"
  }                                
}
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.dual_stack_public_route_table.id
}
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.dual_stack_public_route_table.id
}

resource "aws_route_table" "dual_stack_private_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ipv4_nat.id
  }
   route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_egress_only_internet_gateway.ipv6_igw.id
  }
  tags = {
    Name = "private_dual_stack_route"
  }
}
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.dual_stack_private_route_table.id
}
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.dual_stack_private_route_table.id
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
# secuirty groups to be added

# nacls to be added