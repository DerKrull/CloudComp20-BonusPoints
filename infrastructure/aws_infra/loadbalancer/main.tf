resource "aws_lb" "rancher_alb" {
  name               = "external-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_for_lb_id]
  subnets            = var.public_subnet_ids
  depends_on         = [var.igw] 
}

resource "aws_lb_target_group" "rancher_control_plane_https_tg" {
  name        = "rancher-control-plane-https-tg"
  port     = 6443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTPS"
    port     = "6443"
    healthy_threshold = 10
    unhealthy_threshold = 10
    timeout = 120
    interval = 300
  }
}

resource "aws_lb_target_group" "rancher_https_tg" {
  name        = "rancher-https-tg"
  port     = 30443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTPS"
    port     = "30443"
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 6
    interval = 10
  }
}

resource "aws_lb_target_group" "rancher_http_tg" {
  name     = "rancher-http-tg"
  port     = 30080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTP"
    port     = "30080"
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 6
    interval = 10
  }
}

resource "aws_lb_listener" "control_plane_https" {
  load_balancer_arn = aws_lb.rancher_alb.arn
  port              = 6443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.rancher_self_signed.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher_control_plane_https_tg.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.rancher_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.rancher_self_signed.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher_https_tg.arn
  }
}


resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.rancher_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher_http_tg.arn
  }
}

resource "tls_private_key" "rancher" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "rancher" {
  private_key_pem = tls_private_key.rancher.private_key_pem
  subject {
    common_name  = "rancher"
    organization = "cloudcomp20"
  }

  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [aws_lb.rancher_alb.dns_name]
}

resource "aws_acm_certificate" "rancher_self_signed" {
  private_key       = tls_private_key.rancher.private_key_pem
  certificate_body  = tls_self_signed_cert.rancher.cert_pem
  certificate_chain = tls_self_signed_cert.rancher.cert_pem
}