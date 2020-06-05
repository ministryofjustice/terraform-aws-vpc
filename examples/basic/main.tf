provider "aws" {
  region = var.region
}

module "vpc" {
  source       = "../../"
  cidr_block   = var.cidr_block
  subnets      = var.subnets
  route_tables = var.route_tables
}
