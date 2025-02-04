provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./network"
}

module "security" {
  source = "./security"
  vpc_id = module.network.vpc_id
}

module "instances" {
  source        = "./instances"
  subnet_id     = module.network.subnet_id
  security_group_id = module.security.security_group_id
}
