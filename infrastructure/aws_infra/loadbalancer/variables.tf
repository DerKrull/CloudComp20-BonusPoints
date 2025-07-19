variable "vpc_id" {
  description = "Id of the VPC"
}
variable "sg_for_lb_id" {
  description = "ID of secruity group for loadbalancer"
}

variable "subnet_ids" {
  description = "List of ids of the subnets"
}

variable "igw" {
  description = "Internet gateway for depend on statement"
}
