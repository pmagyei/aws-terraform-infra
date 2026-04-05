output "vpc_id" {
    value = aws_vpc.dev_vpc.id
}
output "vpv_ipv4_cidr" {
    value = aws_vpc.dev_vpc.cidr_block
}
output "vpv_ipv6_cidr" {
    value = aws_vpc.dev_vpc.ipv6_cidr_block
}
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
output "APP_SERVER_A_ipv4" {
    value = aws_instance.app-serve_a.private_ip  
}
output "APP_SERVER_A_ipv6" {
    value = aws_instance.app_server_a.ipv6_addresses[0]
}
output "APP_SERVER_B_ipv4" {
    value = aws_instance.app-serve_b.private_ip  
}
output "APP_SERVER_B_ipv6" {
    value = aws_instance.app_server_b.ipv6_addresses[0]
}
