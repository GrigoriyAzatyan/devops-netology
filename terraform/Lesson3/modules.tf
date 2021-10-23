module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "aws_instance"

  ami                    = data.aws_ami.latest-ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "my-key"
  tags = {
    Name = "My_third_EC2" 
  }
}

