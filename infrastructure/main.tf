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

module "aws_infra" {
  source = "./aws_infra"
  providers = {
    aws = aws
  }
  group_name = local.group_name
}


module "openstack-rke2" {
  source   = "./terraform-openstack-rke2/examples/hs-fulda/"
  project  = var.openstack-project
  password = var.openstack-password
  username = var.openstack-username
}

#token eyJhIjoiY2Y5MGVjNGE3ZDM4NDExMGU2ODFlN2EyMmU1MDI1YWYiLCJ0IjoiZDQwZTRiM2YtYzM3MS00MzFiLWJhZWMtM2MzNzZlNTlhZTFjIiwicyI6Ik5HRTFaRGd5T1RRdE9UWm1OaTAwT0dFeExUa3haRE10TkdVM01HWTBaR1ZpWVRaaCJ9
