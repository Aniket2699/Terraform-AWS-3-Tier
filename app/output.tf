output "private_ip" {
  value = aws_instance.app.private_ip
  description = "Private IP of the app instance"
}
