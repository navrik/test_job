resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
      Name = "${var.vpc_name}-public"
    }
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.igw.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
