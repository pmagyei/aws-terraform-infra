output "app_server_a_instance_id" {
  description = "The instance ID of app_server_a"
  value       = aws_instance.app_server_a.id
}

output "app_server_a_private_ip" {
  description = "The private IP of app_server_a"
  value       = aws_instance.app_server_a.private_ip
}