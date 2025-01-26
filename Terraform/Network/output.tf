output "subnet_id" {
  value = aws_subnet.public_subnet_assignment1.id
}

output "vpc_id" {
  value = aws_default_vpc.default_vpc.id
}