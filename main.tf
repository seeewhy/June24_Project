provider "aws" {
  region     = "us-east-2"
  access_key = ""
  secret_key = ""
}


#resource "aws_instance" "first_ubuntu_instance" {
 # ami                     = "ami-085f9c64a9b75eed5"
  #instance_type           = "t2.micro"
#}

# Create a VPC
resource "aws_vpc" "prodvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Production_VPC"
  }
}


# Create a Subnet

resource "aws_subnet" "prodsubnet1" {
  vpc_id     = aws_vpc.prodvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"

  tags = {
    Name = "Subnet-Prod"
  }
}
# Create an Internet Gateway

resource "aws_internet_gateway" "Igw" {
  vpc_id     = aws_vpc.prodvpc.id

  tags = {
    Name = "IGW_NEW"
  }
}
# Create a Route Table

resource "aws_route_table" "prodroute" {
  vpc_id     = aws_vpc.prodvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }

  
  tags = {
    Name = "RT"
  }
}


# Associate subnet with Route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prodsubnet1.id
  route_table_id = aws_route_table.prodroute.id
}
# Create a security group

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id     = aws_vpc.prodvpc.id

ingress {
    description = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS Traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # any protocol ip address
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_tls"
  }
}


# Create a Instance and attach security group

resource "aws_instance" "first_ubuntu_instance" {
  ami                     = "ami-085f9c64a9b75eed5"
  instance_type           = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id      = aws_subnet.prodsubnet1.id
  availability_zone = "us-east-2a"
  count = 2


 tags = {
    Name = "Terraform_Server"
  }


}
