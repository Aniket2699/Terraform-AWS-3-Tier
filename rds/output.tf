
output "db_name"    { value = aws_db_instance.db.db_name }
output "db_address" {
  value = aws_db_instance.db.endpoint
}
