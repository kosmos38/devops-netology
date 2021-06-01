# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
  #access_key = "my-access-key"
  #secret_key = "my-secret-key"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "netology-ubuntu"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "My first instance"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance