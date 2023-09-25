provider "aws" {
  region = "us-east-1"
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow inbound traffic ssh"

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  }

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.allow_ssh.id
  network_interface_id = aws_instance.web.primary_network_interface_id
}

resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami = "ami-0fc5d935ebf8bc3bc"
  key_name      = aws_key_pair.ssh_key.key_name

  user_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo docker run -d --name wordpress -p 80:80 wordpress
EOF
 }

resource "aws_eip" "elasticip" {
  instance = aws_instance.web.id  
 }

output "EIP" {
value = aws_eip.elasticip.public_ip
 }
