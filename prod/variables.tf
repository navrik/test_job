variable "eks_cluster_name" {
  default = "test-prod"
}

variable "thumbprint_list" {
  type = list
  default = [
    "111" # eu-central-1
  ]
}

variable "aws_account_number" {
  default = "111"
}
