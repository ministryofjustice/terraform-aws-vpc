variable "vpc_name" {
  description = "name of the vpc"
  type        = string
  default     = ""
}

variable "igw_name" {
  description = "name of the igw"
  type        = string
  default     = ""
}

variable "vgw_name" {
  description = "name of the vgw"
  type        = string
  default     = ""
}

variable "amazon_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway"
  type        = string
  default     = ""
}

variable "private_virtual_interfaces" {
  description = "A map of private virtual interfaces"
  type        = map
  default     = {}
}

variable "subnets" {
  description = "Map of subnets to create in the vpc."
  type        = map(any)
}

variable "route_tables" {
  description = "map of routes to create in the vpc"
  type        = map(any)
  default     = {}
}


variable "cidr_block" {
  description = "cidr block for the vpc"
  type        = string
}

variable "secondary_cidr_blocks" {
  description = "list of secondary cidr blocks to associate with the vpc"
  type        = list(string)
  default     = []
}

variable "vpc_tags" {
  description = "Optional Tags to apply to VPC"
  type        = map(any)
  default     = {}
}


variable "tags" {
  description = "Optional Tags to apply to all resources"
  type        = map(any)
  default     = {}
}

variable "security_groups" {
  description = "Map of security groups to create"
}

variable "tgw_vpc_attachment" {
  description = "Map of TGW VPC attachement parameters"
  default     = {}
}

variable "public_ipv4_pool" {
  type    = string
  default = "amazon"
}

variable "nat_gateway" {
  description = "Map of NAT gateway parameters"
  type        = map(any)
  default     = {}
}
