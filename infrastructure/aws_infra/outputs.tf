output "kubeconfig_path" {
    value = local_file.kubeconfig.filename
}

output "load_balancer_dns" {
    value = module.loadbalancer.lb_internal_dns
}
