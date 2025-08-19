resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "proj5-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "proj5-igw" }
}

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_az1
  availability_zone       = "${data.aws_region.current.name}a"
  map_public_ip_on_launch = true
  tags = { Name = "public-az1" }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_az2
  availability_zone       = "${data.aws_region.current.name}b"
  map_public_ip_on_launch = true
  tags = { Name = "public-az2" }
}

resource "aws_subnet" "private_az1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_az1
  availability_zone = "${data.aws_region.current.name}a"
  tags = { Name = "private-az1" }
}

resource "aws_subnet" "private_az2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_az2
  availability_zone = "${data.aws_region.current.name}b"
  tags = { Name = "private-az2" }
}

data "aws_region" "current" {}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "proj5-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_az1.id
  tags          = { Name = "proj5-nat" }
  depends_on    = [aws_internet_gateway.igw]
}

# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "proj5-public-rt" }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_az1" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_az1.id
}
resource "aws_route_table_association" "public_az2" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_az2.id
}

# Private route table -> NAT
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "proj5-private-rt" }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_az1" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_az1.id
}
resource "aws_route_table_association" "private_az2" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_az2.id
}
