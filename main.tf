data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 0 )
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 1 )
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 2 )
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 3 )
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_route_table" "public_subnet_1_route_table" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_subnet_1_rt"
  }
}

resource "aws_route_table_association" "public_subnet_1_route_table_associate" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_1_route_table.id
}

resource "aws_route_table" "public_subnet_2_route_table" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_subnet_2_rt"
  }
}

resource "aws_route_table_association" "public_subnet_2_route_table_associate" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_subnet_2_route_table.id
}

resource "aws_route_table" "private_subnet_1_route_table" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "private_subnet_1_rt"
  }
}

resource "aws_route_table_association" "private_subnet_1_route_table_associate" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_subnet_1_route_table.id
}

resource "aws_route_table" "private_subnet_2_route_table" {
  vpc_id = aws_vpc.this.id
  tags = {
    "name" = "private_subnet_2_rt"
  }
}

resource "aws_route_table_association" "private_subnet_2_route_table_associate" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_subnet_2_route_table.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "value"
  }
}

resource "aws_eip" "nat_eip_1" {
  vpc = true
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_eip" "nat_eip_2" {
  vpc = true
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id = aws_subnet.private_subnet_1.id
  tags = {
    Name = "nat-gw-1"
  }
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id = aws_subnet.private_subnet_2.id
  tags = {
    Name = "nat-gw-2"
  }
}