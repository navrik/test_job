resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name          = var.dhcp_domain_name
  domain_name_servers  = var.dhcp_domain_name_servers

  tags = {
    Name = "${var.vpc_name}-dhcp"
  }
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}
