resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/23" # 512 IPs
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Creating 1st public subnet
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/27" #32 IPs
  map_public_ip_on_launch = true          # public subnet
  availability_zone       = "us-east-1a"
}

# Creating 2nd public subnet
resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.32/27" #32 IPs
  map_public_ip_on_launch = true           # public subnet
  availability_zone       = "us-east-1b"
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.main.id
}

# route table for public subnet - connecting to Internet gateway
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
}

# associate the route table with public subnet 1
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.rt_public.id
}

# associate the route table with public subnet 2
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.rt_public.id
}
