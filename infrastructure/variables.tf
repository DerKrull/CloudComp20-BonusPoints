variable "group_number" {
  default = "20"
  type    = string
}
variable "openstack-project" {
  default = "CloudComp20"
}
variable "openstack-username" {
  default = "CloudComp20"
}
variable "openstack-password" {

}
# Cloudflare variables
variable "cloudflare_zone" {
  description = "Domain used to expose the GCP VM instance to the Internet"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID for your domain"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Account ID for your Cloudflare account"
  type        = string
  sensitive   = true
}

variable "cloudflare_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}
