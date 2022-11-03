#
# RDS variables
#

variable "cluster_identifier" {
  default = ""
}

variable "database_name" {
  default = ""
}

variable "master_username" {
  default = ""
}

variable "master_password" {
  default = ""
}

variable "security_group_ids" {
  default = ""
}

variable "subnet_ids" {
  default = ""
}

variable "instances_number" {
  default = ""
}

variable "instance_class" {
  default = ""
}

variable "max_connections" {
  default = ""
}

variable "skip_rds_cluster_creation" {
  default = false
}
