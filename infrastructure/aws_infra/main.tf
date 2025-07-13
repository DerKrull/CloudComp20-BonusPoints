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

module "vpc" {
    source = "./vpc"
}

module "route53" {
  source = "./route53"
  group_name = var.group_name
  vpc_id = module.vpc.vpc_id
}

module "secruity" {
    source = "./secruity"
    vpc_id = module.vpc.vpc_id
}

module "loadbalancer" {
    source = "./loadbalancer"
    vpc_id = module.vpc.vpc_id
    igw = module.vpc.igw
    public_subnet_ids = [module.vpc.public_subnet_1a_id, module.vpc.public_subnet_1b_id]
    sg_for_lb_id = module.secruity.sg_for_lb_id
}

module "ec2" {
    source = "./ec2"
    rancher_https_tg_arn = module.loadbalancer.rancher_https_tg_arn
    rancher_http_tg_arn = module.loadbalancer.rancher_http_tg_arn
    rancher_control_https_tg_arn = module.loadbalancer.rancher_control_plane_http_tg_arn
    lb_dns_name = module.loadbalancer.lb_internal_dns
    subnet_id = module.vpc.public_subnet_1a_id
    sg_for_ec2_id = module.secruity.sg_for_ec2_id
    hosted_zone_id = module.route53.hosted_zone_id
    internal_dns = module.route53.internal_dns
}

resource "local_file" "kubeconfig" {
  filename = "rke2.yaml"
  content = ""
}

resource "null_resource" "download_kubeconfig" {
  provisioner "local-exec" {
    command = <<EOT
      aws s3 cp s3://cloudcomp20-terraform-state-bucket/rke2.yaml rke2.yaml
      sed -i 's/127.0.0.1/${module.loadbalancer.lb_internal_dns}/g' rke2.yaml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    always_run = "${timestamp()}"
    load_balancer_dns  = module.loadbalancer.lb_internal_dns
  }
}