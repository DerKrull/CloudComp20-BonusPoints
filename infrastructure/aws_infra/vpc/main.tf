resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/23" # 512 IPs 
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
# Creating 1st private subnet 
resource "aws_subnet" "private_subnet_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/27" #32 IPs
  map_public_ip_on_launch = false         # private subnet
  availability_zone       = "us-east-1a"
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

# Elastic IP for NAT gateway
resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.internet_gw]
  domain = "vpc"
  tags = {
    Name = "EIP_for_NAT"
  }
}

# NAT gateway for private subnets 
# (for the private subnet to access internet - eg. ec2 instances downloading softwares from internet)
resource "aws_nat_gateway" "nat_for_private_subnet" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet_1a.id # nat should be in public subnet

  tags = {
    Name = "NAT for private subnet"
  }

  depends_on = [aws_internet_gateway.internet_gw]
}

# route table - connecting to NAT
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_for_private_subnet.id
  }
}

# associate the route table with private subnet
resource "aws_route_table_association" "rta3" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.rt_private.id
}