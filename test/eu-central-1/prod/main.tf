terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.13.0"
    }
  }

  backend "s3" {
    bucket         = "test-tf-state"
    key            = "network-core/prod"
    dynamodb_table = "test-tf-state"
    region         = "eu-central-1"
  }
}

module "vpc" {
  source = "../../../vpc"

  azs_number                 = length(var.azs)
  azs                        = var.azs
  cidr_block                 = var.cidr_block
  vpc_name                   = var.vpc_name
  dhcp_domain_name           = var.dhcp_domain_name
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
}
