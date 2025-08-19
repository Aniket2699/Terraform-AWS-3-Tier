# Web SG - allow HTTP from internet
resource "aws_security_group" "web" {
  name        = "proj5-web-sg"
  description = "Allow HTTP from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "proj5-web-sg" }
}

# App SG - allow HTTP only from Web SG
resource "aws_security_group" "app" {
  name        = "proj5-app-sg"
  description = "Allow HTTP only from Web SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from Web"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "proj5-app-sg" }
}

# DB SG - allow 3306 only from App SG
resource "aws_security_group" "db" {
  name        = "proj5-db-sg"
  description = "RDS access only from App"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from App"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "proj5-db-sg" }
}
