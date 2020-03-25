## Tom's VPC Module
### Overview
My personal module for creating a vpc with some subnets. Use if you'd like.

### Usage
```
provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "../../"
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
  region     = "eu-north-1"
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

