terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  region = "ap-east-1"
  profile = "default"	
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# create key pair
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.key.public_key_openssh
}

# find latest ami
data "aws_ami" "amazon-linux-2-ami" {
 most_recent = true
 owners      = ["amazon"]
# filter {
#  name   = "owner-alias"
#  values = ["amazon"]
# }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm-*-x86_64-gp2"]
 }
}

# provides details about the specific VPC
data "aws_vpc" "dev_vpc" {
  id = var.vpc_id
}

# create sg for full node
resource "aws_security_group" "fullnode-sg" {
  name        = "fullnode-sg"
  description = "Allow internal traffic"
  vpc_id      = var.vpc_id
  ingress {
    description      = "ssh for VPC internal ansible"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.dev_vpc.cidr_block]
  }

  ingress {
    from_port = 26657 
    to_port = 26657
    protocol = "tcp"
    description = "Tendermint port for internal access"
    cidr_blocks = [data.aws_vpc.dev_vpc.cidr_block]
  }

  ingress {
    from_port = 1317
    to_port = 1317
    protocol = "tcp"
    description = "Cosmos port for internal access"
    cidr_blocks = [data.aws_vpc.dev_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "fullnode-sg"
  }
}

# create aws instance for testnet full node, naming pattern {infra env + staging env + purpose}
resource "aws_instance" "fullnode" {
  ami           = data.aws_ami.amazon-linux-2-ami.id
  instance_type = "t3.small"
  key_name      = aws_key_pair.generated_key.key_name
  root_block_device {
   # delete_on_termination = false
    volume_size = 30
    volume_type = "gp2"
  } 
  vpc_security_group_ids = [aws_security_group.fullnode-sg.id]
  subnet_id              = var.private_subnet_id
  tags = {
    Name = "awsdevtestnetnode"
    Environment = "dev"
  }
}


# full node ip output
output "privateip"{
  value = aws_instance.fullnode.private_ip
}


# copy ip into a file in local
resource "local_file" "ip" {
    content  = aws_instance.fullnode.private_ip
    filename = "fullnode_ip"
}

# copy private key into a file in local
resource "local_file" "kp" {
    content  = tls_private_key.key.private_key_pem
    filename = "${var.key_name}.pem" 
}

# add deplay to wait for ec2 reachable
resource "time_sleep" "wait" {
  depends_on = [local_file.kp]

  destroy_duration = var.time_sleep
}

# execute ansible playbook
resource "null_resource" "ansible" {
    depends_on = [
      time_sleep.wait
    ]
    provisioner "local-exec" {
      command = "chmod 400 ${var.key_name}.pem && cd ../ansible && ansible-playbook main.yml"
    }
}
