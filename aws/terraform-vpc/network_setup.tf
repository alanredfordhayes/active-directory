resource "aws_vpc" "vpc_active_directory" {
  provider             = aws
  cidr_block           = "10.100.0.0/22"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = {
    Name               = "active_directory"
  }

}

resource "aws_internet_gateway" "internet_route" {
  provider  = aws
  vpc_id    = aws_vpc.vpc_active_directory.id
  tags      = {
      Name  = "internet_route"
  }
}

resource "aws_route_table" "internet_route" {
  provider          = aws
  vpc_id            = aws_vpc.vpc_active_directory.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.internet_route.id
  }
  lifecycle {
    ignore_changes  = all
  }
  tags              = {
    Name            = "internet_route"
  }
}

data "aws_availability_zones" "azs" {
  provider          = aws
  state             = "available"
}

resource "aws_subnet" "external_a" {
  provider          = aws
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_active_directory.id
  cidr_block        = "10.100.1.0/25"

  tags              = {
    Name            = "external_a"
  }
}

resource "aws_eip" "external_a" {
  vpc               = true
}

resource "aws_nat_gateway" "external_a" {
  allocation_id = aws_eip.external_a.id
  subnet_id     = aws_subnet.external_a.id

  tags          = {
    Name        = "external_a"
  }
}

resource "aws_route_table_association" "external_a" {
  subnet_id      = aws_subnet.external_a.id
  route_table_id = aws_route_table.internet_route.id
}

resource "aws_subnet" "external_b" {
  provider          = aws
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc_active_directory.id
  cidr_block        = "10.100.1.128/25"

  tags              = {
    Name            = "external_b"
  }
}

resource "aws_eip" "external_b" {
  vpc               = true
}

resource "aws_nat_gateway" "external_b" {
  allocation_id = aws_eip.external_b.id
  subnet_id     = aws_subnet.external_b.id

  tags          = {
    Name        = "external_b"
  }
}

resource "aws_route_table_association" "external_b" {
  subnet_id      = aws_subnet.external_b.id
  route_table_id = aws_route_table.internet_route.id
}

resource "aws_subnet" "internal_a" {
  provider          = aws
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_active_directory.id
  cidr_block        = "10.100.2.0/25"

  tags              = {
    Name            = "internal_a"
  }
}

resource "aws_route_table" "internal_a" {
  provider          = aws
  vpc_id            = aws_vpc.vpc_active_directory.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_nat_gateway.external_a.id
  }
  lifecycle {
    ignore_changes  = all
  }
  tags              = {
    Name            = "internal_a"
  }
}

resource "aws_route_table_association" "internal_a" {
  subnet_id      = aws_subnet.internal_a.id
  route_table_id = aws_route_table.internal_a.id
}

resource "aws_subnet" "internal_b" {
  provider          = aws
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc_active_directory.id
  cidr_block        = "10.100.2.128/25"

  tags              = {
    Name            = "internal_b"
  }
}

resource "aws_route_table" "internal_b" {
  provider          = aws
  vpc_id            = aws_vpc.vpc_active_directory.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_nat_gateway.external_b.id
  }
  lifecycle {
    ignore_changes  = all
  }
  tags              = {
    Name            = "internal_b"
  }
}

resource "aws_route_table_association" "internal_b" {
  subnet_id      = aws_subnet.internal_b.id
  route_table_id = aws_route_table.internal_b.id
}