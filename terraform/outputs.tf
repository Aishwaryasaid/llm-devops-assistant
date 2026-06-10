output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "app_url" {
  description = "URL to access the DevOps assistant"
  value       = "http://${aws_instance.app.public_ip}:8000"
}
