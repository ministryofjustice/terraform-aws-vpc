output "subnets" {
  value = module.vpc.subnets
}

output "rt" {
  value = module.vpc.route_tables
}

output "vpc" {
  value = module.vpc.vpc
}

