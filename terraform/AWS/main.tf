provider "aws" {
   region = "eu-west-2"
}

data "aws_ami" "latest-ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_instance" "ec2" {
   ami = data.aws_ami.latest-ubuntu.id
   instance_type = "t3.micro"
   key_name = "my-key"
   tags = {
     Name = "My_first_EC2" 
   }
}
