variable "cidr_block" {
  default = "10.190.0.0/16"
}

variable "vpc_name" {
  default = "prod-vpc"
}

variable "dhcp_domain_name" {
  default = "eu-central-1.compute.internal"
}

variable "azs" {
  type = list
  default = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]
}

variable "private_subnet_cidr_blocks" {
  type = list
  default = [
    "10.190.0.0/19",
    "10.190.32.0/19",
    "10.190.64.0/19"
  ]
}

variable "public_subnet_cidr_blocks" {
  type = list
  default = [
    "10.190.96.0/19",
    "10.190.128.0/19",
    "10.190.160.0/19"
  ]
}
