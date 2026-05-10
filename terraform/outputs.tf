output "app_server_a_ipv4_ipv6_ip" {
    value = [
        aws_instance.app_server_a.private_ip,
        aws_instance.app_server_a.ipv6_addresses
    ] 
}