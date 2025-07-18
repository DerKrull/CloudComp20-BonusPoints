variable "subnet_b_id" {
  description = "Subnet id of the subnet"
}

variable "subnet_a_id" {
  description = "Subnet id of the subnet"
}

variable "sg_for_ec2_id" {
  description = "ID of the secruity group to use with EC2"
}

variable "rancher_https_tg_arn" {
  description = "ARN of the target group to attach to"
}

variable "rancher_control_https_tg_arn" {
  description = "ARN of the target group to attach to"
}

variable "rancher_http_tg_arn" {
  description = "ARN of the target group to attach to"
}

variable "lb_dns_name" {
  description = "Internal DNS name of the load balancer"
}

variable "hosted_zone_id" {
  description = "Id of the private hosted zone"
}

variable "internal_dns" {
  description = "Domain name of the private hosted zone"
}

variable "ssh_authorized_keys" {

}
