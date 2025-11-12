terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "emart-vpc" }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags = { Name = "emart-subnet" }
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
  tags = { Name = "emart-sg" }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              set -e
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user || true
              # pull and run the site image
              docker pull esha0629/emart-site:latest || true
              docker rm -f emart-site || true
              docker run -d --name emart-site -p 80:80 --restart=always esha0629/emart-site:latest
              EOF

  tags = { Name = "emart-web" }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
