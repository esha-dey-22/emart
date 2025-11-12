terraform {
  required_providers { aws = { source = "hashicorp/aws" } }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-west-2"     # change as needed
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "emart-vpc" }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_security_group" "sg" {
  name        = "emart-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name", values = ["amzn2-ami-hvm-*-x86_64-gp2"] }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name      = var.key_name   # create or supply existing keypair

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              # Pull the docker image from Docker Hub and run
              docker pull yourdockerhubusername/emart-site:latest || true
              docker run -d --restart=always -p 80:80 yourdockerhubusername/emart-site:latest
              EOF

  tags = { Name = "emart-web" }
}
