resource "aws_subnet" "public_subnets" {
  count                   = var.azs_number
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${element(split("-", var.vpc_name), 0)}-${element(split("-", var.vpc_name), 1)}-public-${element(split("-", element(var.azs, count.index)),2)}"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table_association" "public_subnets" {
  count          = var.azs_number
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.igw.id
}
