#############################
# VPC and Networking Setup  #
#############################

resource "aws_vpc" "main" {
  # checkov:skip=CKV2_AWS_11:VPC flow logs should be enabled in all VPCs
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-vpc"
    },
  )
}

# Default Security Group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-default-sg"
    },
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  # checkov:skip=CKV_AWS_130:Public subnet can assign public IP addresses
  count                   = var.number_of_availability_zones
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-public-subnet"
    },
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count                   = var.number_of_availability_zones
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-private-subnet"
    },
  )
}

# Internet Gateway: to allow incoming traffic from the internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-igw"
    },
  )
}

# Public Route Table: send all traffic to the internet gateway
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-public-subnet-route-table"
    },
  )
}

# Private Route Table: no outgoing traffic to the internet
resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-private-subnet-route-table"
    },
  )
}

# Associate public subnets to the public route table
resource "aws_route_table_association" "public" {
  count          = var.number_of_availability_zones
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_table.id
}

# Associate private subnets to the private route table
resource "aws_route_table_association" "private" {
  count          = var.number_of_availability_zones
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_table.id
}