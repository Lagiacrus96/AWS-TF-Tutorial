provider "aws" {
  profile = "default"
  region = "eu-central-1"
}

# Create a VPC
resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.vpc_name
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "terraform_igw"
  }
}

# Create a public route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "Public route table"
  }
}

# Create a private route table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "Private route table"
  }
}

# Create a public security group
resource "aws_security_group" "public-sg" {
  description = "Allow SSH, HTTP, and HTTPS inbound traffic and all outbound traffic"
  name = "public-sg"
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "publicSG"
  }
}
# Create a security group CURRENTLY UNUSED
resource "aws_security_group" "private-sg" {
  description = "Allow SSH, HTTP, and HTTPS inbound traffic and all outbound traffic"
  name = "private-sg"
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "privateSG"
  }
}

# Allow inbound SSH traffic
resource "aws_security_group_rule" "ssh_access" {
  security_group_id = aws_security_group.public-sg.id
  type               = "ingress"
  from_port          = 22
  to_port            = 22
  protocol           = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

}

# Allow inbound HTTP traffic
resource "aws_security_group_rule" "http_access" {
  security_group_id = aws_security_group.public-sg.id
  type               = "ingress"
  from_port          = 80
  to_port            = 80
  protocol           = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

}

# Allow inbound HTTPS traffic
resource "aws_security_group_rule" "https_access" {
  security_group_id = aws_security_group.public-sg.id
  type               = "ingress"
  from_port          = 443
  to_port            = 443
  protocol           = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

}

# Allow all outbound traffic
resource "aws_security_group_rule" "outbound_access" {
  security_group_id = aws_security_group.public-sg.id
  type               = "egress"
  from_port          = 0
  to_port            = 0
  protocol           = -1
  cidr_blocks       = ["0.0.0.0/0"]

}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route-table.id
}


# Create a public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Public Subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "Private Subnet"
  }
}

# Create a key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair" 
  public_key = file("~/.ssh/terraform_rsa.pub") 

  tags = {
    Name = "My Key Pair"
  }
}

# Create a public instance
resource "aws_instance" "public-instance" {
  ami = "ami-0f673487d7e5f89ca" # AWS Linux 2
  instance_type = var.instance_type
  subnet_id = aws_subnet.public-subnet.id
  key_name = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true
  security_groups = [ aws_security_group.public-sg.id ]
  tags = {
    Name = var.public_instance_name
  }
}

# Create a private instance
resource "aws_instance" "private-instance" {
  ami = "ami-0f673487d7e5f89ca" # AWS Linux 2
  instance_type = var.instance_type
  subnet_id = aws_subnet.private-subnet.id
  key_name = aws_key_pair.my_key_pair.key_name # TODO: Change this to another key pair
  associate_public_ip_address = false
  security_groups = [ aws_security_group.public-sg.id ]
  tags = {
    Name = var.private_instance_name
  }
}

# Create an EIP for the NAT gateway
resource "aws_eip" "eip" {
  domain   = "vpc"
}

# Create a NAT gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}