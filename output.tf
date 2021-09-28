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

output "security_groups" {
  description = "Security group attributes"
  value       = aws_security_group.this
}

output "tgw_vpc_attachment_id" {
  description = "Transit Gateway VPC attachment ID"
  value       = length(aws_ec2_transit_gateway_vpc_attachment.this) == 0 ? null : aws_ec2_transit_gateway_vpc_attachment.this[0].id
}
