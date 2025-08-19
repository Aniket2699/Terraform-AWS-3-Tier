resource "aws_db_subnet_group" "dbsub" {
  name       = "proj5-db-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = { Name = "proj5-db-subnet-group" }
}

resource "aws_db_instance" "db" {
  identifier                 = "proj5-mydb"
  engine                     = "mysql"
  engine_version             = "8.0"
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  db_name                    = var.db_name
  username                   = var.username
  password                   = var.password
  db_subnet_group_name       = aws_db_subnet_group.dbsub.name
  vpc_security_group_ids     = var.vpc_security_group_ids
  multi_az                   = false
  publicly_accessible        = false
  skip_final_snapshot        = true
  deletion_protection        = false
  storage_encrypted          = true
  backup_retention_period    = 0

  tags = { Name = "proj5-rds" }
}
