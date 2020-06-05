locals {
  routes = flatten([
    for rtb, rts in var.route_tables : [
      for rt in rts : [
        merge(rt, { "rtb" = rtb })
      ]
    ]
  ])
}

# Create VPC resources
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags       = merge(var.tags, var.vpc_tags, { Name = var.vpc_name })
}

resource "aws_subnet" "this" {
  for_each          = var.subnets
  cidr_block        = each.value.cidr
  availability_zone = lookup(each.value, "az", null)
  tags              = merge(var.tags, lookup(each.value, "tags", {}), { Name = each.key })
  vpc_id            = aws_vpc.this.id
}

# Create and associate Route tables#### 
resource "aws_route_table" "this" {
  for_each = { for rt in var.subnets : rt.route_table => rt... }
  vpc_id   = aws_vpc.this.id
  tags     = merge(var.tags, { Name = each.key })
}

resource "aws_route_table_association" "this" {
  for_each       = var.subnets
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.value.route_table].id
}

# TGW VPC attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  count              = lookup(var.tgw_vpc_attachment, "tgw_id", null) != null ? 1 : 0
  vpc_id             = aws_vpc.this.id
  subnet_ids         = [for subnet in var.tgw_vpc_attachment.subnets : aws_subnet.this[subnet].id]
  transit_gateway_id = var.tgw_vpc_attachment.tgw_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(var.tags, { Name = var.vpc_name })
}


# Configure IGW if igw_name is specified  #### 
resource "aws_internet_gateway" "this" {
  count  = var.igw_name != "" ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, var.vpc_tags, { Name = var.igw_name })
}

# Allocate an EIP for NAT GW
resource "aws_eip" "nat_gw_eip" {
  count            = length(var.nat_gateway) != 0 ? 1 : 0
  vpc              = true
  public_ipv4_pool = var.public_ipv4_pool
}

# Configure NAT GW if nat_gateway is specified  #### 
resource "aws_nat_gateway" "this" {
  count         = length(var.nat_gateway) != 0 ? 1 : 0
  allocation_id = aws_eip.nat_gw_eip[0].id
  subnet_id     = aws_subnet.this[lookup(var.nat_gateway, "subnet")].id

  # NAT Gateway depends on the Internet Gateway for the VPC in which the NAT Gateway's subnet is located
  depends_on = [aws_internet_gateway.this, aws_subnet.this]
}

# Target type - igw
resource "aws_route" "igw_rt" {
  for_each               = { for r in local.routes : "${r.rtb}-${r.destination_cidr}" => r if r.target == "igw" }
  route_table_id         = aws_route_table.this[each.value.rtb].id
  destination_cidr_block = each.value.destination_cidr
  gateway_id             = aws_internet_gateway.this[0].id
}

# Target type - natgw
resource "aws_route" "natgw_rt" {
  for_each               = { for r in local.routes : "${r.rtb}-${r.destination_cidr}" => r if r.target == "natgw" }
  route_table_id         = aws_route_table.this[each.value.rtb].id
  destination_cidr_block = each.value.destination_cidr
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

# Target type - tgw
resource "aws_route" "tgw_rt" {
  for_each               = { for r in local.routes : "${r.rtb}-${r.destination_cidr}" => r if r.target == "tgw" }
  route_table_id         = aws_route_table.this[each.value.rtb].id
  destination_cidr_block = each.value.destination_cidr
  transit_gateway_id     = var.tgw_vpc_attachment.tgw_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}

# Security groups
resource "aws_security_group" "this" {
  for_each = var.security_groups
  name     = each.key
  vpc_id   = aws_vpc.this.id

  dynamic "ingress" {
    for_each = [
      for rule in each.value :
      rule
      if rule.type == "ingress"
    ]

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = lookup(ingress.value, "description", "")
    }
  }

  dynamic "egress" {
    for_each = [
      for rule in each.value :
      rule
      if rule.type == "egress"
    ]

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = lookup(egress.value, "description", "")
    }
  }

  tags = merge(var.tags, var.vpc_tags, { Name = each.key })
}

# TGW route table associations
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  count                          = lookup(var.tgw_vpc_attachment, "association_rtb", null) != null ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[0].id
  transit_gateway_route_table_id = var.tgw_vpc_attachment.association_rtb
}

# TGW route table propagations
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  count                          = lookup(var.tgw_vpc_attachment, "propagation_rtb", null) != null ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[0].id
  transit_gateway_route_table_id = var.tgw_vpc_attachment.propagation_rtb
}
