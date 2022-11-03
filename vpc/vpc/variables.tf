variable "cidr_block" {
}

variable "enable_dns_support" {
  default = true
}

variable "enable_dns_hostnames" {
  default = true
}

variable "vpc_name" {
}

variable "dhcp_domain_name" {
}

variable "dhcp_domain_name_servers" {
  type = list
  default = ["AmazonProvidedDNS"]
}

variable "azs" {
  type = list
}

variable "azs_number" {
}

variable "private_subnet_cidr_blocks" {
  type = list
}

variable "public_subnet_cidr_blocks" {
  type = list
}
