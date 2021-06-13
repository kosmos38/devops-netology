locals {
  web_instance_type_map = {
    stage = "t2.micro"
    prod = "t4g.micro"
  }
  
  web_instance_count_map = {
    stage = 1
    prod = 2
  }
 
  web_instance_each_map = {
    prod = {
      ubuntu-web-prod-1 = "t4g.micro"
      ubuntu-web-prod-2 = "t4g.micro" 
    }
    stage = {
      ubuntu-web-stage-1 = "t2.micro"
    }
  }[terraform.workspace]
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
  #access_key = "my-access-key"
  #secret_key = "my-secret-key"
}

# Используем образ ubuntu
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

  owners = ["099720109477"] # Canonical
}

data "aws_caller_identity" "web" {}

data "aws_region" "web" {}

resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  count = local.web_instance_count_map[terraform.workspace]
  tags = {
    Name = "ubuntu-web-${count.index + 1}"
  }
}

resource "aws_instance" "web-test" {
  ami = data.aws_ami.ubuntu.id
  instance_type = each.value
  for_each = local.web_instance_each_map
      tags = {
    Name = "${each.key}"
  }
}
