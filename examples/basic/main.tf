provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "../../"
  cidr_block = var.cidr_block
  subnets    = var.subnets
  #  public_rts = var.public_rts
}
