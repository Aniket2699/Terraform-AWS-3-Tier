terraform {
  required_version = "~> 1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Key Pair
resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${path.module}/tf-key-pair.pem"
}

module "vpc" {
  source = "./vpc"

  vpc_cidr            = "10.0.0.0/16"
  public_subnet_az1   = "10.0.1.0/24"
  public_subnet_az2   = "10.0.2.0/24"
  private_subnet_az1  = "10.0.3.0/24"
  private_subnet_az2  = "10.0.4.0/24"
}

module "security" {
  source = "./security"

  vpc_id = module.vpc.vpc_id
}

module "app" {
  source        = "./app"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.vpc.private_subnet_az1_id
  key_name      = aws_key_pair.tf-key-pair.key_name
  app_sg_id     = module.security.app_sg_id
  db_host       = module.rds.db_address  # ✅ use the output
  db_username   =         var.db_username
  db_password   =      var.db_password
  db_name       = var.db_name
  db_address    = module.rds.db_address
}


module "web" {
  source = "./web"

  ami_id           = var.ami_id
  instance_type    = var.instance_type
  subnet_id        = module.vpc.public_subnet_az1_id
  key_name         = aws_key_pair.tf-key-pair.key_name
  web_sg_id        = module.security.web_sg_id
  app_private_ip   = module.app.private_ip  # used in Nginx proxy_pass
}

module "rds" {
  source = "./rds"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_ids          = [module.vpc.private_subnet_az1_id, module.vpc.private_subnet_az2_id]
  vpc_security_group_ids = [module.security.db_sg_id]
}