output "internal_dns" {
  value = aws_route53_zone.private.name
}

output "hosted_zone_id" {
  value = aws_route53_zone.private.id
}

output "rancher_master_dns" {
  value       = aws_route53_record.rancher_master.name
  description = "FQDN für den Rancher Master Server"
}