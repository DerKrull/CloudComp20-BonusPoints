resource "aws_route53_zone" "private" {
    name              = "${var.group_name}.internal"
    vpc {
        vpc_id = var.vpc_id
    }
    comment           = "Private hosted zone for EC2 instance management"
    force_destroy     = true
    
}