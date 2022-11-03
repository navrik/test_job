resource "aws_subnet" "private_subnets" {
  count             = var.azs_number
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${element(split("-", var.vpc_name), 0)}-${element(split("-", var.vpc_name), 1)}-private-${element(split("-", element(var.azs, count.index)), 2)}"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table_association" "private_subnets" {
  count          = var.azs_number
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.nat.id
}
