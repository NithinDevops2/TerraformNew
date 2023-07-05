provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.20.0.0/16"

  tags = {
    Name = "MyVPC"
  }
}

#subnet 1

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "172.20.10.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "Subnet1"
  }
}

#subnet 2

resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "172.20.20.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "Subnet2"
  }
}

#internet gateway

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyIGW"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }


  tags = {
    Name = "MyRouteTable"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.my_route_table.id
}

#attach internet gateway to vpc

/* resource "aws_internet_gateway_attachment" "my_vpc_attachment" {
  internet_gateway_id = aws_internet_gateway.my_igw.id
  vpc_id              = aws_vpc.my_vpc.id
} */

#NAT gateway

/* resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.subnet2.id
}
 */
#elastic ip for NAT gateway

/* resource "aws_eip" "my_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.my_igw]
} */

#ec2 in subnet1

resource "aws_instance" "instance_subnet1" {
  ami = "ami-0bb6af715826253bf"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
 #user_data = "${file("java_install.sh")}"

  tags = {
    Name = "EC2Instance_Subnet1"
  }
}

resource "null_resource" "install_java" {
  provisioner "remote-exec" {
    connection {
      #type = "ssh"
      host     = aws_instance.instance_subnet1.public_ip
      user     = "centos"
      password = "DevOps321"
    }
    inline = [
      "mkdir newfolder2"
      ]
  }
}

#ec2 in subnet2

resource "aws_instance" "instance_subnet2" {
  ami = "ami-0bb6af715826253bf"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = {
    Name = "EC2Instance_Subnet2"
  }
}

resource "aws_security_group" "instance_sg" {
  name = "instance_sg"
  description = "Security group for EC2 instances"
  
  vpc_id = aws_vpc.my_vpc.id
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}