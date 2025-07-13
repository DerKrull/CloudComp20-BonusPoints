locals {
  domain_name = "${var.group_name}.internal"
}

resource "aws_route53_zone" "private" {
    name              = local.domain_name
    vpc {
        vpc_id = var.vpc_id
    }
    comment           = "Private hosted zone for EC2 instance management"
    force_destroy     = true
    
}

# A-Record für den Rancher Master Server
resource "aws_route53_record" "rancher_master" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "rke2-master.${local.domain_name}"
  type    = "A"
  ttl     = 300

  # Platzhalter-IP, wird durch EC2 User Data Script aktualisiert
  records = ["127.0.0.1"]

  # Erlaubt Überschreibung durch User Data Script
  lifecycle {
    ignore_changes = [records]
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
    domain_name = local.domain_name
    domain_name_servers = ["169.254.169.253"]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}