## VPC Module

### Usage
```
provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "git::https://gitlab.com/public-tf-modules/terraform-aws-vpc?ref=v0.1.0"
  vpc_name   = "example"
  igw_name   = "example-IGW"
  subnets = {
    Pub-a  = { cidr = "10.253.100.0/24", az = "eu-west-2a", route_table = "Public" },
    Pub-b  = { cidr = "10.253.200.0/24", az = "eu-west-2b", route_table = "Public" },
    Priv-a = { cidr = "10.253.11.0/24", az = "eu-west-2a", route_table = "Priv" },
    Priv-b = { cidr = "10.253.12.0/24", az = "eu-west-2b", route_table = "Priv" },
    TGW-a  = { cidr = "10.253.1.0/24", az = "eu-west-2a", route_table = "TGW" },
    TGW-b  = { cidr = "10.253.2.0/24", az = "eu-west-2b", route_table = "TGW" },
    Mgmt-a = { cidr = "10.253.110.0/24", az = "eu-west-2a", route_table = "Mgmt" },
    Mgmt-b = { cidr = "10.253.120.0/24", az = "eu-west-2b", route_table = "Mgmt" }
  }
  security_groups = {
    Public-sg = [
      { description = "https", protocol = "TCP", from_port = 443, to_port = 443, cidr_blocks = ["137.83.198.1/32", "90.254.209.65/32"], type = "ingress" },
      { description = "ssh", protocol = "TCP", from_port = 22, to_port = 22, cidr_blocks = ["137.83.198.1/32", "90.254.209.65/32"], type = "ingress" },
      { description = "allow-all", protocol = -1, from_port = 0, to_port = 0, cidr_blocks = ["0.0.0.0/0"], type = "egress" }
    ],
    Priv-sg = [
      { description = "allow-all", protocol = -1, from_port = 0, to_port = 0, cidr_blocks = ["0.0.0.0/0"], type = "egress" },
      { description = "allow-all", protocol = -1, from_port = 0, to_port = 0, cidr_blocks = ["10.0.0.0/8"], type = "ingress" }
    ]
  }
  route_tables = {
    "Public" = [
      { destination_cidr = "0.0.0.0/0", target = "igw" }
    ],
    "Priv" = [
      { destination_cidr = "10.0.0.0/8", target = "tgw" }
    ],
    "Mgmt" = [
      { destination_cidr = "0.0.0.0/0", target = "igw" },
      { destination_cidr = "192.168.100.0/24", target = "tgw" }
    ]
  }
  tgw_vpc_attachment = {
    tgw_id          = data.terraform_remote_state.tgw.outputs.tgws["TGW-MoJ"].id,
    subnets         = ["TGW-a", "TGW-b"]
    propagation_rtb = data.terraform_remote_state.tgw.outputs.tgw_rtbs["tgw-rtb-security"].id
    association_rtb = data.terraform_remote_state.tgw.outputs.tgw_rtbs["tgw-rtb-security"].id
  }
  cidr_block = "10.253.0.0/16"
}
```
## Providers

| Name | Version |
|------|---------|
| aws | ~> 2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| cidr\_block | cidr block for the vpc | `string` | n/a | yes |
| subnets | Map of subnets to create in the vpc. | `map(any)` | n/a | yes |
| security\_groups | Map of security groups to be later used with EC2 | `map(any)` | `{}` | no |
| route\_tables | Map of route tables | `map(any)` | n/a | yes |
| tags | Optional Tags to apply to all resources | `map(any)` | `{}` | no |
| tgw\_vpc\_attachment | Optional map if VPC need to be attached to a TGW | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| route\_tables | Route table attributes |
| subnets | Subnet attributes |
| vpc | VPC attributes |
| security\_groups | Security Group attributes |

