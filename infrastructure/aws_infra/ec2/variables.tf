variable "subnet_id" {
    description = "Subnet id of the subnet"
}

variable "sg_for_ec2_id" {
  description = "ID of the secruity group to use with EC2"
}

variable "rancher_tcp_443_tg_arn" {
    description = "ARN of the target group to attach to"
}

variable "rancher_tcp_80_tg_arn" {
    description = "ARN of the target group to attach to"
}

variable "rancher_master_tg_arn" {
    description = "ARN of the target group to attach to"
}

variable "lb_dns_name" {
    description = "Internal DNS name of the load balancer"
}

