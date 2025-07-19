locals {
  group_name     = "CloudComp${var.group_number}"
  ssh_public_key = "~/.ssh/id_ed25519.pub"
  openstack = {
    insecure         = true
    cacert_file      = "${path.module}/openstack_infra/os-trusted-cas"
    auth_url         = "https://private-cloud.informatik.hs-fulda.de:5000/v3"
    object_store_url = "https://10.32.4.32:443"
    region           = "RegionOne"
  }
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
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}



provider "openstack" {
  insecure    = local.insecure
  tenant_name = var.project
  user_name   = var.username
  password    = var.password
  auth_url    = local.auth_url
  region      = local.region
  cacert_file = local.cacert_file
}

# module "aws_infra" {
#   source = "./aws_infra"
#   providers = {
#     aws = aws
#   }
#   group_name          = local.group_name
#   ssh_authorized_keys = [local.ssh_public_key]
# }

module "openstack-rke2" {
  source = "./openstack_infra"
  providers = {
    openstack = openstack
  }
  project          = var.openstack-project
  password         = local.openstack.group_name
  username         = local.openstack.group_name
  insecure         = local.openstack.insecure
  auth_url         = local.openstack.auth_url
  object_store_url = local.openstack.object_store_url
}
