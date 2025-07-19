module "vpc" {
  source = "./vpc"
}

module "route53" {
  source     = "./route53"
  group_name = var.group_name
  vpc_id     = module.vpc.vpc_id
}

module "secruity" {
  source = "./secruity"
  vpc_id = module.vpc.vpc_id
}

module "loadbalancer" {
  source       = "./loadbalancer"
  vpc_id       = module.vpc.vpc_id
  igw          = module.vpc.igw
  subnet_ids   = [module.vpc.public_subnet_1a_id, module.vpc.public_subnet_1b_id]
  sg_for_lb_id = module.secruity.sg_for_lb_id
}

module "ec2" {
  source                       = "./ec2"
  rancher_https_tg_arn         = module.loadbalancer.rancher_https_tg_arn
  rancher_http_tg_arn          = module.loadbalancer.rancher_http_tg_arn
  rancher_control_https_tg_arn = module.loadbalancer.rancher_control_plane_http_tg_arn
  lb_dns_name                  = module.loadbalancer.lb_internal_dns
  subnet_a_id                  = module.vpc.public_subnet_1a_id
  subnet_b_id                  = module.vpc.public_subnet_1b_id
  sg_for_ec2_id                = module.secruity.sg_for_ec2_id
  hosted_zone_id               = module.route53.hosted_zone_id
  internal_dns                 = module.route53.internal_dns
  ssh_authorized_keys          = var.ssh_authorized_keys
}

module "rke2" {
  source                = "./rke2"
  depends_on            = [module.ec2]
  rke2_server_id        = module.ec2.rke2_server_bootstrap_id
  rke2_server_publid_ip = module.ec2.rke2_server_bootstrap_public_ipv4
  lb_dns_name           = module.loadbalancer.lb_internal_dns
}
