###########################################################
#
# Author: Lucas Immanuel Nickel, Sebastian Rieger
# Date: November 16, 2024
# Remark: This code is not production ready as it disables certificate checks by default
# and sets kubeconfig file access to 644 instead of default 600
#
###########################################################

locals {
  cluster_name     = "${var.project}-k8s"
  image_name       = "ubuntu-22.04-jammy-server-cloud-image-amd64"
  flavor_name      = "m1.medium"
  system_user      = "ubuntu"
  floating_ip_pool = "ext_net"
  ssh_pubkey_file  = "~/.ssh/id_ed25519.pub"
  dns_server       = "10.33.16.100"
  manifests_folder = "${path.module}/hsfd-manifests"
  rke2_version     = "v1.30.3+rke2r1"

  ###########################################################
}

module "rke2" {
  #source = "zifeo/rke2/openstack"
  source              = "../downloaded_modules/terraform-openstack-rke2"
  insecure            = var.insecure
  bootstrap           = true
  name                = local.cluster_name
  ssh_authorized_keys = [local.ssh_pubkey_file]
  floating_pool       = local.floating_ip_pool
  # should be restricted to secure bastion
  rules_ssh_cidr = ["0.0.0.0/0"]
  rules_k8s_cidr = ["0.0.0.0/0"]
  # auto load manifest from a folder (https://docs.rke2.io/advanced#auto-deploying-manifests)
  manifests_folder = local.manifests_folder

  servers = [{
    name               = "controller"
    flavor_name        = local.flavor_name
    image_name         = local.image_name
    system_user        = local.system_user
    boot_volume_size   = 6
    rke2_version       = local.rke2_version
    rke2_volume_size   = 10
    rke2_volume_device = "/dev/vdb"
    # https://docs.rke2.io/install/install_options/server_config/
    rke2_config = <<EOF
# https://docs.rke2.io/install/install_options/server_config/
write-kubeconfig-mode: "0644"
EOF
  }]

  agents = [
    {
      name        = "worker"
      nodes_count = 2
      flavor_name = local.flavor_name
      image_name  = local.image_name
      # if you want a fixed version
      # image_uuid = "..."
      system_user        = local.system_user
      boot_volume_size   = 6
      rke2_version       = local.rke2_version
      rke2_volume_size   = 8
      rke2_volume_device = "/dev/vdb"
    }
  ]

  backup_schedule  = "0 6 1 * *" # once a month
  backup_retention = 20

  kube_apiserver_resources = {
    requests = {
      cpu    = "75m"
      memory = "128M"
    }
  }

  kube_scheduler_resources = {
    requests = {
      cpu    = "75m"
      memory = "128M"
    }
  }

  kube_controller_manager_resources = {
    requests = {
      cpu    = "75m"
      memory = "128M"
    }
  }

  etcd_resources = {
    requests = {
      cpu    = "75m"
      memory = "128M"
    }
  }
  #vip_interface       = "ens2"
  dns_nameservers4 = [local.dns_server]
  # enable automatically agent removal of the cluster (wait max for 30s)
  ff_autoremove_agent = "30s"
  # rewrite kubeconfig
  ff_write_kubeconfig = true
  # deploy etcd backup
  ff_native_backup = true
  # wait for the cluster to be ready when deploying
  ff_wait_ready = true

  identity_endpoint     = var.auth_url
  object_store_endpoint = var.object_store_url
}

terraform {
  required_version = ">= 0.14.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 2.0.0"
    }
  }
}
