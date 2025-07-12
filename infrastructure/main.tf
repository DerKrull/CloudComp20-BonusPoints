locals {
  group_name = "cloudcomp${var.group_number}"
}

module "aws_infra" {
    source = "./aws_infra"
    group_name = local.group_name
}

# module "openstack-rke2" {
#     source = "./terraform-openstack-rke2/examples/hs-fulda/"
#     project = var.openstack-project
#     password = var.openstack-password
#     username = var.openstack-username
# }