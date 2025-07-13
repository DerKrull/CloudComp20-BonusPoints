output "rancher_https_tg_arn" {
    value = aws_lb_target_group.rancher_https_tg.arn
}
output "rancher_http_tg_arn" {
    value = aws_lb_target_group.rancher_http_tg.arn
}
output "rancher_control_plane_http_tg_arn" {
    value = aws_lb_target_group.rancher_control_plane_https_tg.arn
}
output "lb_internal_dns" {
    value = aws_lb.rancher_alb.dns_name
}