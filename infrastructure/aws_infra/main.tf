terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


# module "aws-rke2" {
#   source  = "rancher/rke2/aws"
#   version = "1.2.6"
# }

module "ec2" {
    source = "./ec2"
    rancher_tcp_443_tg_arn = module.loadbalancer.rancher_tcp_443_tg_arn
    rancher_tcp_80_tg_arn = module.loadbalancer.rancher_tcp_80_tg_arn
    rancher_master_tg_arn = module.loadbalancer.rancher_master_tg_arn
    lb_dns_name = module.loadbalancer.lb_internal_dns
    subnet_id = module.vpc.public_subnet_1a_id
    sg_for_ec2_id = module.secruity.sg_for_ec2_id
}

module "loadbalancer" {
    source = "./loadbalancer"
    vpc_id = module.vpc.vpc_id
    igw = module.vpc.igw
    public_subnet_ids = [module.vpc.public_subnet_1a_id, module.vpc.public_subnet_1b_id]
    sg_for_lb_id = module.secruity.sg_for_lb_id
}

module "vpc" {
    source = "./vpc"
}

module "secruity" {
    source = "./secruity"
    vpc_id = module.vpc.vpc_id
}