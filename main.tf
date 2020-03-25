### Create VPC resources
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags       = merge(var.tags, var.vpc_tags)
}

resource "aws_subnet" "this" {
  for_each          = var.subnets
  cidr_block        = each.value.cidr
  availability_zone = lookup(each.value, "az", null)
  tags              = merge(var.tags, lookup(each.value, "tags", {}), { Name = each.key })
  vpc_id            = aws_vpc.this.id
}

#### Create and associate Route tables#### 
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


#### Easy mode for public subnets  #### 
resource "aws_internet_gateway" "this" {
  count  = length(var.public_rts) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, var.vpc_tags)
}

resource "aws_route" "public" {
  for_each               = toset(var.public_rts)
  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}
