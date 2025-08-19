output "vpc_id"                  { value = aws_vpc.my_vpc.id }
output "public_subnet_az1_id"    { value = aws_subnet.public_az1.id }
output "public_subnet_az2_id"    { value = aws_subnet.public_az2.id }
output "private_subnet_az1_id"   { value = aws_subnet.private_az1.id }
output "private_subnet_az2_id"   { value = aws_subnet.private_az2.id }
