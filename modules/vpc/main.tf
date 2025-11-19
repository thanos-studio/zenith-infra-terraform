locals {
  # Get all Availability zones (A, B, C, D is avail for Seoul)
  azs = data.aws_availability_zones.available.names

  # Get the CIDR prefix of the VPC
  vpc_cidr_prefix = tonumber(split("/", var.vpc_cidr)[1])
  subnet_newbits  = 24 - local.vpc_cidr_prefix # Get a newbits to calculate subnet cidrs

  # Calculate public subnet cidrs (xxx.xxx.1/2/3.xxx)
  public_subnet_cidrs = [
    for i in range(length(local.azs)) :
    cidrsubnet(var.vpc_cidr, local.subnet_newbits, i + 1)
  ]

  # Calculate private subnet cidrs (xxx.xxx.11/12/13.xxx)
  private_subnet_cidrs = [
    for i in range(length(local.azs)) :
    cidrsubnet(var.vpc_cidr, local.subnet_newbits, i + 11)
  ]

  # Calculate Protected subnet cidrs (xxx.xxx.21/22/23.xxx)
  protected_subnet_cidrs = [
    for i in range(length(local.azs)) :
    cidrsubnet(var.vpc_cidr, local.subnet_newbits, i + 21)
  ]
}

### --------------------------------------------------
### AWS Subnets
### --------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames                 = true # Enable DNS hostnames for the VPC
  enable_dns_support                   = true # Enable DNS support for the VPC
  enable_network_address_usage_metrics = true # Enable network address usage metrics for the VPC

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

### --------------------------------------------------
### AWS Subnets
### --------------------------------------------------
# Public subnets (1 per AZ)
resource "aws_subnet" "public" {
  count = length(local.public_subnet_cidrs) # Create a subnet for each AZ

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  map_public_ip_on_launch = true # Allocate a public IP address to the subnet's resources

  tags = {
    Name = "${var.prefix}-public-subnet-${local.azs[count.index]}"
  }
}

# Private subnets (1 per AZ)
resource "aws_subnet" "private" {
  count = length(local.private_subnet_cidrs) # Create a subnet for each AZ

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.prefix}-private-subnet-${local.azs[count.index]}"
  }
}

# Protected subnets (1 per AZ)
resource "aws_subnet" "protected" {
  count = length(local.protected_subnet_cidrs) # Create a subnet for each AZ

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.protected_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.prefix}-protected-subnet-${local.azs[count.index]}"
  }
}

### --------------------------------------------------
### Gateways and EIPs
### --------------------------------------------------
# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  count  = length(local.azs) # Create an EIP(Reserve IP) for each AZ
  domain = "vpc"
  tags = {
    Name = "${var.prefix}-nat-eip-${local.azs[count.index]}"
  }
}

resource "aws_eip" "bastion_eip" {
  # Create an EIP(Reserve IP) for the bastion host
  domain = "vpc"
  tags = {
    Name = "${var.prefix}-bastion-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = length(local.azs)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.prefix}-nat-${local.azs[count.index]}"
  }

  depends_on = [aws_internet_gateway.main]
}

### --------------------------------------------------
### Route Tables and Routes
### --------------------------------------------------
# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-public-route-table"
  }
}

# Public route to Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Public route table association
resource "aws_route_table_association" "public" {
  count          = length(local.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route table
resource "aws_route_table" "private" {
  count  = length(local.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-private-route-table-${local.azs[count.index]}"
  }
}

# Private route to NAT Gateway
resource "aws_route" "private_nat_access" {
  count                  = length(local.private_subnet_cidrs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Private route table association
resource "aws_route_table_association" "private" {
  count          = length(local.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Protected route table
resource "aws_route_table" "protected" {
  count  = length(local.protected_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-protected-route-table-${local.azs[count.index]}"
  }
}

resource "aws_route_table_association" "protected" {
  count          = length(local.protected_subnet_cidrs)
  subnet_id      = aws_subnet.protected[count.index].id
  route_table_id = aws_route_table.protected[count.index].id
}

### --------------------------------------------------
### Bastion Host
### --------------------------------------------------
# Security group for the bastion host
resource "aws_security_group" "bastion" {
  name        = "${var.prefix}-bastion-security-group"
  description = "Security group for the bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-bastion-security-group"
  }
}

# Bastion host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.bastion_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.bastion_key_name
  iam_instance_profile   = var.bastion_instance_profile_name

  tags = {
    Name = "${var.prefix}-bastion"
  }
}

# Associate the bastion host with bastion eip
resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}