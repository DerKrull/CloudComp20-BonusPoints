output "sg_for_lb_id" {
    value = aws_security_group.sg_for_elb.id
}

output "sg_for_ec2_id" {
    value = aws_security_group.sg_for_ec2.id
}