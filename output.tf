output "web_public_dns" {
  description = "Public DNS of the web server"
  value       = module.web.web_public_dns
}

output "web_public_ip" {
  description = "Public IP of the web server"
  value       = module.web.web_public_ip
}

output "app_private_ip" {
  description = "Private IP of the app server"
  value       = module.app.private_ip
}

output "db_address" {
  description = "RDS endpoint hostname"
  value       = module.rds.db_address
}

output "db_name" {
  value = module.rds.db_name
}
