output "rancher_tcp_443_tg_arn" {
    value = aws_lb_target_group.rancher_tcp_443_tg.arn
}

output "rancher_tcp_80_tg_arn" {
    value = aws_lb_target_group.rancher_tcp_80_tg.arn
}

output "rancher_master_tg_arn" {
    value = aws_lb_target_group.rancher_master_tg.arn
}

output "lb_internal_dns" {
    value = aws_lb.lb.dns_name
}