#provider "aws" {
#  region = var.region
#}

#resource "aws_internet_gateway_attachment" "gw" {
#  internet_gateway_id = aws_internet_gateway.test-terraform-ig.id
#  vpc_id              = aws_vpc.vpc-subnet.id
#}

resource "aws_vpc" "vpc-subnet" {
  cidr_block           = var.vpc_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "vpc-subnet"
  }
}

resource "aws_subnet" "test-terraform-subnet" {
  vpc_id                  = aws_vpc.vpc-subnet.id
  cidr_block              = var.subnet_block
  map_public_ip_on_launch = "true"
  tags = {
    Name = "test-terraform-subnet"
  }
}

resource "aws_internet_gateway" "test-terraform-ig" {
  vpc_id = aws_vpc.vpc-subnet.id
  tags = {
    Name = "test-terraform-ig"
  }
}

resource "aws_route_table" "test-terraform-rt" {
  vpc_id = aws_vpc.vpc-subnet.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-terraform-ig.id
  }
  tags = {
    Name = "test-terraform-rt"
  }
}

resource "aws_route_table_association" "test-terraform-rtas" {
  subnet_id      = aws_subnet.test-terraform-subnet.id
  route_table_id = aws_route_table.test-terraform-rt.id
}

resource "aws_security_group" "test-terraform-sg" {
  name        = "test-terraform-sg"
  description = "Trafico permitido de la instancia"
  vpc_id      = aws_vpc.vpc-subnet.id
  tags = {
    Name = "test-terraform-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.test-terraform-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.test-terraform-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.test-terraform-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_instance" "test-terraform-ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = "sshkey-test01"
  subnet_id                   = aws_subnet.test-terraform-subnet.id
  vpc_security_group_ids      = [aws_security_group.test-terraform-sg.id]
  associate_public_ip_address = "true"
  tags = {
    Name = "test-terraform-ec2"
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/ubuntu/terraform/sshkey-test01.pem")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo yum install -y git",
      "sudo git clone https://github.com/mauricioamendola/chaos-monkey-app.git /var/www/html",
      #"echo test > test.txt",
    ]
  }
}
