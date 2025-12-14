terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"  
}

resource "aws_security_group" "sg" {
  name = "security-group"


  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port  = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8086
    to_port = 8086
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "exam"
  }
}


resource "aws_instance" "server" {
  ami                    = "ami-0f50f13aefb6c0a5d"  
  instance_type          = "t3.micro"              
  vpc_security_group_ids = [aws_security_group.sg.id]


  key_name = "ec2-key-pair"  


  tags = {
    Name = "exam"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -a -G docker ec2-user
              EOF
}


output "server_ip" {
  value = aws_instance.server.public_ip
  description = "Публічний ІP адрес сервера"
}

output "server_url" {
  value = "http://${aws_instance.server.public_ip}"
  description = "Посилання для доступу до програми"
}