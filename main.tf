data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 0)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.vpc_name}-public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.vpc_name}-public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 2)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.vpc_name}-private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 3)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.vpc_name}-private_subnet_2"
  }
}

resource "aws_route_table" "public_subnet_1_route_table" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public_subnet_1_rt"
  }
}

resource "aws_route_table_association" "public_subnet_1_route_table_associate" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_1_route_table.id
}

resource "aws_route_table" "public_subnet_2_route_table" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public_subnet_2_rt"
  }
}

resource "aws_route_table_association" "public_subnet_2_route_table_associate" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_subnet_2_route_table.id
}

resource "aws_route_table" "private_subnet_1_route_table" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-private_subnet_1_rt"
  }
}

resource "aws_route" "private_subnet_1_to_nat_gateway" {
  route_table_id         = aws_route_table.private_subnet_1_route_table.id
  nat_gateway_id         = aws_nat_gateway.nat_1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_subnet_1_route_table_associate" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_subnet_1_route_table.id
}

resource "aws_route_table" "private_subnet_2_route_table" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "${var.vpc_name}-private_subnet_2_rt"
  }
}

resource "aws_route" "private_subnet_2_to_nat_gateway" {
  route_table_id         = aws_route_table.private_subnet_2_route_table.id
  nat_gateway_id         = aws_nat_gateway.nat_2.id
  destination_cidr_block = "0.0.0.0/0"
}


resource "aws_route_table_association" "private_subnet_2_route_table_associate" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_subnet_2_route_table.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_eip" "nat_eip_1" {
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.vpc_name}-eip-1"
  }
}

resource "aws_eip" "nat_eip_2" {
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.vpc_name}-eip-1"
  }
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "${var.vpc_name}-nat-gw-1"
  }
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
  tags = {
    Name = "${var.vpc_name}-nat-gw-2"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = {
    Name = "${var.vpc_name}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint_route_table_association" "vpce-s3-1" {
  route_table_id  = aws_route_table.private_subnet_1_route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "vpce-s3-2" {
  route_table_id  = aws_route_table.private_subnet_2_route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
