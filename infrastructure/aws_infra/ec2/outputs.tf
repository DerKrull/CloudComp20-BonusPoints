output "rke2_server_bootstrap_id" {
  value = module.rke2_server_bootstrap.id
}

output "rancher_server_ids" {
  value = [module.rke2_server.*.id]
}

output "rke2_server_bootstrap_public_ipv4" {
  value = module.rke2_server_bootstrap.public_ip
}
