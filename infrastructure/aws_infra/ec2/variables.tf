variable "private_subnet_1a_id" {
    description = "Subnet id of the private subnet in 1a"
}

variable "sg_for_ec2_id" {
  description = "ID of the secruity group to use with EC2"
}

variable "alb_tg_arn" {
    description = "ARN of the target group to attach to"
}

