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
  value = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]
}
output "private_subnet_ids" {
  value = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]
}
output "app_server_a_ipv4_ipv6_ip" {
    value = [
        aws_instance.app_server_a.private_ip,
        aws_instance.app_server_a.ipv6_addresses
    ] 
}
output "app_server_b_ipv4_ipv6_ip" {
    value = [
        aws_instance.app_server_b.private_ip, 
        aws_instance.app_server_b.ipv6_addresses   
    ] 
}