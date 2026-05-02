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
  map_public_ip_on_launch = true #used for ssh for bastion host /jumpbox
  assign_ipv6_address_on_creation = true
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
  assign_ipv6_address_on_creation = true
  availability_zone = "eu-west-2b"
  tags = {
    Name = "private_subnet_b"
  }
}

#ipv4
resource "aws_eip" "bastion_eip" {
  domain = "vpc"
  instance = aws_instance.bastion_host
  tags = {
    Name = "bastion-eip"
  }
}

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


# public route table associations                     
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

# private route table associations

}
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.dual_stack_private_route_table.id
}
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.dual_stack_private_route_table.id
}

# nacls public
resource "aws_network_acl" "public_dual_stack" {
  vpc_id = aws_vpc.dev_vpc.id

  #icmp ipv4
  ingress {
    protocol   = "1"
    rule_no    = 90
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = "1"
    rule_no    = 90
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  #icmp ipv6
  ingress {
    protocol   = "58"
    rule_no    = 91
    action     = "allow"
    ipv6_cidr_block = "::/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "58"
    rule_no    = 91
    action     = "allow"
    ipv6_cidr_block = "::/0"
    from_port  = 0
    to_port    = 0
  }
 
 #https inbound
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  #https ephemeral ports outbound
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  egress {
    protocol   = "tcp"
    rule_no    = 301
    action     = "allow"
    ipv6_cidr_block = "::/0"
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "DEV_PUBLIC_NACL"
  }
  
}

# nacls private

resource "aws_network_acl" "private_dual_stack" {
  vpc_id = aws_vpc.dev_vpc.id


  ingress {
    protocol = "tcp"
    rule_no = 80
    action = "allow"
    cidr_block = "10.10.10.64/27"
    from_port = 22
    to_port = 22
  }

    egress {
    protocol   = "tcp"
    rule_no    = 80
    action     = "allow"
    cidr_block = "10.10.10.64/27"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "1"
    rule_no    = 90
    action     = "allow"
    cidr_block = "10.10.10.0/25"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = "1"
    rule_no    = 90
    action     = "allow"
    cidr_block = "10.10.10.0/25"
    from_port  = 0
    to_port    = 0
  }

  #allow icmp ipv6
  egress {
    protocol   = "58"
    rule_no    = 91
    action     = "allow"
    ipv6_cidr_block = "::/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "58"
    rule_no    = 91
    action     = "allow"
    ipv6_cidr_block = "::/0"
    from_port  = 0
    to_port    = 0
  }

  #allow https inbound
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.10.10.0/25"
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    ipv6_cidr_block = "::/0"
    from_port  = 443
    to_port    = 443
  }
  #alllows https outbound
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.10.10.0/25"
    from_port  = 1024
    to_port    = 65535
  }
  egress {
    protocol   = "tcp"
    rule_no    = 301
    action     = "allow"
    ipv6_cidr_block = "::/0"
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "DEV_PRIVATE_NACL"
  }  

# nacl associations
}
resource "aws_network_acl_association" "public_a" {
  network_acl_id = aws_network_acl.public_dual_stack.id
  subnet_id      = aws_subnet.public_subnet_a.id
}
resource "aws_network_acl_association" "public_b" {
  network_acl_id = aws_network_acl.public_dual_stack.id
  subnet_id      = aws_subnet.public_subnet_b.id
}
resource "aws_network_acl_association" "private_a" {
  network_acl_id = aws_network_acl.private_dual_stack.id
  subnet_id      = aws_subnet.private_subnet_a.id
}
resource "aws_network_acl_association" "private_b" {
  network_acl_id = aws_network_acl.private_dual_stack.id
  subnet_id      = aws_subnet.private_subnet_b.id
}

# secuirty groups 
resource "aws_security_group" "dual_stack_IP" {
  name = "dual-stack_ip"
  description = "Allow IPv4 & IPv6 web traffic"
  vpc_id = aws_vpc.dev_vpc.id

  # allow SSH 

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.10.10.64/27"]
    #ipv6_cidr_blocks = ["::/0"]
    description = "SSH accesss"
}

  # Allow HTTP from IPv4 + IPv6
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "HTTP from IPv4 + IPv6"
}

   # Allow HTTPS from IPv4 + IPv6
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

    description = "HTTPS from IPv4 + IPv6"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all outbound"
  }

  tags = {
    Name = "dual-stack-web-sg"
  }
}

# bastion SG

resource "aws_security_group" "ssh"{
  vpc_id      = dev_vpc.id
  description = "Allow SSH to bastion host"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["10.168.139.107/32"]
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

}


#bation host

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = var.public_key
  
}

resource "aws_instance" "bastion_host" {
  ami = var.aws_ami_image
  instance_type = var.aws_instance_type
  subnet_id = aws_subnet.public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "bastion_host"
  }
}
# EC2 instance
resource "aws_instance" "app_server_a" {
  ami = var.aws_ami_image
  instance_type = var.aws_instance_type
  subnet_id = aws_subnet.private_subnet_a.id
  monitoring = true

  vpc_security_group_ids = [aws_security_group.dual_stack_IP.id]
  tags = {
    Name = "APP_SERVER_A"
  }
}
resource "aws_instance" "app_server_b" {
  ami = var.aws_ami_image
  instance_type = var.aws_instance_type
  subnet_id = aws_subnet.private_subnet_b.id
  monitoring = true

  vpc_security_group_ids = [aws_security_group.dual_stack_IP.id]
  tags = {
    Name = "APP_SERVER_B"
  }
}

# rds instance to be added


