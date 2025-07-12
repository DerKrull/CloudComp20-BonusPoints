output "internal_dns" {
  value = aws_route53_zone.private.name
}

output "hosted_zone_id" {
  value = aws_route53_zone.private.id
}