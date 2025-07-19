

# Creates a new remotely-managed tunnel.
resource "cloudflare_zero_trust_tunnel_cloudflared" "openstack_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "Tofu Openstack tunnel"
}

# Reads the token used to run the tunnel on the server.
data "cloudflare_zero_trust_tunnel_cloudflared_token" "openstack_tunnel_token" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.openstack_tunnel.id
}


resource "cloudflare_dns_record" "openstack" {
  zone_id = var.cloudflare_zone_id
  name    = "openstack-rke2"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.openstack_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

# Configures tunnel with a public hostname route for clientless access.
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "openstack_tunnel_config" {
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.openstack_tunnel.id
  account_id = var.cloudflare_account_id
  config = {
    ingress = [
      {
        hostname = "openstack.${var.cloudflare_zone}"
        service  = "https://kubernetes.default.svc.cluster.local:443"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

# TODO
# Deploy cloudflared to openstack cluster with helm
#
