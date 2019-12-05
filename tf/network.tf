resource "aws_vpc" "main" {
  cidr_block = "172.17.0.0/16"
}

data "aws_availability_zones" "available" {
}

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
}