resource "aws_lb" "lb" {
  name               = "external-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_for_lb_id]
  subnets            = var.public_subnet_ids
  depends_on         = [var.igw]
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}