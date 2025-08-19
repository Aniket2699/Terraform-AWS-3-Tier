variable "ami_id"        {
   type = string 
default = "ami-020cba7c55df1f615"
}
variable "instance_type" { type = string }
variable "subnet_id"     { type = string }
variable "key_name"      { type = string }
variable "app_sg_id"     { type = string }

variable "db_address" {}
variable "db_username" {}
variable "db_password" {}
variable "db_name" {}
variable "db_host" {
  
}