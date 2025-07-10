module "aws_infra" {
    source = "./aws_infra"
}

# module "openstack-rke2" {
#     source = "./terraform-openstack-rke2/examples/hs-fulda/"
#     project = var.openstack-project
#     password = var.openstack-password
#     username = var.openstack-username
# }