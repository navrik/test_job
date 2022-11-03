resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.vpc_name}-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public_subnets.*.id, 0)

  tags = {
    Name = "${var.vpc_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "nat" {
    vpc_id = aws_vpc.main.id

    tags = {
      Name = "${var.vpc_name}-private"
    }
}

resource "aws_route" "nat_egress" {
  route_table_id         = aws_route_table.nat.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
