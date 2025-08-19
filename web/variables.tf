variable "ami_id"        { 
  type = string
  default = "ami-020cba7c55df1f615" 
  }
variable "instance_type" { type = string }
variable "subnet_id"     { type = string }
variable "key_name"      { type = string }
variable "web_sg_id"     { type = string }
variable "app_private_ip"{ type = string }
