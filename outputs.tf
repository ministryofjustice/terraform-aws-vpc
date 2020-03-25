output "vpc" {
  description = "VPC attributes"
  value       = aws_vpc.this
}

output "subnets" {
  description = "Subnet attributes"
  value       = aws_subnet.this
}

output "route_tables" {
  description = "Route table attributes"
  value       = aws_route_table.this
}

