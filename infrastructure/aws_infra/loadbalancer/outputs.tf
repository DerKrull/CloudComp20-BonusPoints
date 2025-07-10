output "rancher_tcp_443_tg_arn" {
    value = aws_lb_target_group.rancher_tcp_443_tg.arn
}

output "rancher_tcp_80_tg_arn" {
    value = aws_lb_target_group.rancher_tcp_80_tg.arn
}