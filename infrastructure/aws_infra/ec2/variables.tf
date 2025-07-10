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

