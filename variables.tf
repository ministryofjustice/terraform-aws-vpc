variable "subnets" {
  description = "Map of subnets to create in the vpc."
  type        = map(any)
}

variable "public_rts" {
  description = "list of public route tables by name"
  type        = list(string)
  default     = []
}

variable "cidr_block" {
  description = "cidr block for the vpc"
  type        = string
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


