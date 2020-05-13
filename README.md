## VPC Module

### Usage
```
provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "git::https://gitlab.com/public-tf-modules/terraform-aws-vpc?ref=v0.1.0"
  vpc_name   = "example"
  subnets = {
    public-1a  = { cidr = "10.0.0.0/24", az = "eu-north-1a", route_table = "public" },
    public-1b  = { cidr = "10.0.1.0/24", az = "eu-north-1b", route_table = "public" },
    private-1a = { cidr = "10.0.8.0/24", az = "eu-north-1a", route_table = "tgw" },
    private-1b = { cidr = "10.0.99.0/24", az = "eu-north-1b", route_table = "private" }
    tgw-1a     = { cidr = "10.0.18.0/24", az = "eu-north-1a", route_table = "tgw" },
    tgw-1b     = { cidr = "10.0.19.0/24", az = "eu-north-1b", route_table = "tgw" },
    mgmt-1a    = { cidr = "10.0.10.0/24", az = "eu-north-1a", route_table = "mgmt" },
    mgmt-1b    = { cidr = "10.0.11.0/24", az = "eu-north-1b", route_table = "mgmt" },
  }
  security_groups = {
    Public = [
      { description = "https", protocol = "TCP", from_port = 443, to_port = 443, cidr_blocks = ["137.83.198.1/32"], type = "ingress" },
      { description = "ssh", protocol = "TCP", from_port = 22, to_port = 22, cidr_blocks = ["137.83.198.1/32"], type = "ingress" },
      { description = "esp", protocol = "UDP", from_port = 4501, to_port = 4501, cidr_blocks = ["10.0.0.0/16"], type = "ingress" },
      { description = "allow-all", protocol = -1, from_port = 0, to_port = 0, cidr_blocks = ["0.0.0.0/0"], type = "egress" }
    ]
  }
  public_rts = ["public"]
  cidr_block = "10.0.0.0/16"
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
| public\_rts | list of public route tables by name | `list(string)` | `[]` | no |
| subnets | Map of subnets to create in the vpc. | `map(any)` | n/a | yes |
| tags | Optional Tags to apply to all resources | `map(any)` | `{}` | no |
| vpc\_tags | Optional Tags to apply to VPC | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| route\_tables | Route table attributes |
| subnets | Subnet attributes |
| vpc | VPC attributes |

