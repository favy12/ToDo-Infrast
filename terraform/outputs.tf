output "app_public_ip" {
  value = aws_instance.todo_app.public_ip
  description = "Public IP address of the EC2 instance running our To-Do app"
}

output "key_name" {
  value       = var.key_name
  description = "The EC2 key pair name used for SSH access"
}
