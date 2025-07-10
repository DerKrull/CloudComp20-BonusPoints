resource "aws_lb" "lb" {
  name               = "external-lb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [var.sg_for_lb_id]
  subnets            = var.public_subnet_ids
  depends_on         = [var.igw] 
}

resource "aws_lb_target_group" "rancher_tcp_443_tg" {
  name     = "rancher-tcp-443"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "TCP"
    port = "80"
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 6
    interval = 10
  }
}

resource "aws_lb_target_group" "rancher_tcp_80_tg" {
  name     = "rancher-tcp-80"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "TCP"
    port = "traffic-port"
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 6
    interval = 10
  }
}

resource "aws_lb_target_group" "rancher_master_tg" {
  name = "rancher-master-tg"
  port = 9345
  protocol = "TCP"
  vpc_id = var.vpc_id

  health_check {
    protocol = "TCP"
    port = "80"
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 6
    interval = 10
  }
}

resource "aws_lb_listener" "listener_443" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher_tcp_443_tg.arn
  }
}

resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rancher_tcp_80_tg.arn
  }
}

resource "aws_lb_listener" "listener_master" {
  load_balancer_arn = aws_lb.lb.arn
  port = "9345"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.rancher_master_tg.arn
  }
}