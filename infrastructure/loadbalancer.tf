resource "aws_lb" "lb" {
  name               = "external-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_for_elb.id]
  subnets            = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]
  depends_on         = [aws_internet_gateway.internet_gw]
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
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