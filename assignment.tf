provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}
resource "aws_vpc" "joston" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "Joston's vpc"
  }
}
resource "aws_subnet" "joston-public" {
  vpc_id                  = aws_vpc.joston.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Joston's-public-subnet"
  }
}
resource "aws_internet_gateway" "joston-igw" {
  vpc_id = aws_vpc.joston.id
  tags = {
    Name = "Joston's-internet-gateway"
  }
}

resource "aws_route_table" "joston-public-route" {
  vpc_id = aws_vpc.joston.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.joston-igw.id
  }
  tags = {
    Name = "Joston's-public-route-table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.joston-public.id
  route_table_id = aws_route_table.joston-public-route.id
}
resource "aws_security_group" "joston-security" {
vpc_id = aws_vpc.joston.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Joston-Security"
  }
}
resource "aws_instance" "my_public_server" {
  subnet_id = aws_subnet.joston-public.id
  ami                     = "ami-0453ec754f44f9a4a"
  instance_type           = "t2.micro"
  key_name = "jos"
  security_groups = [aws_security_group.joston-security.id]
  user_data  = templatefile("./ansible.sh", {})
  tags= {
    Name = "joston's_public_server"
  }
  }
