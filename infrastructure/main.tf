locals {
  group_name = "cloudcomp${var.group_number}"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "helm" {
  kubernetes = {
    config_path = "${module.aws_infra.kubeconfig_path}"
  }
}

module "aws_infra" {
    source = "./aws_infra"
    providers = {
      aws = aws
    }
    group_name = local.group_name
}

# module "helm_charts" {
#     depends_on = [ module.aws_infra ]
#     providers = {
#       helm = helm
#     }
#     source = "./helm_charts"
#     load_balancer_dns = module.aws_infra.load_balancer_dns
# }

# module "openstack-rke2" {
#     source = "./terraform-openstack-rke2/examples/hs-fulda/"
#     project = var.openstack-project
#     password = var.openstack-password
#     username = var.openstack-username
# }