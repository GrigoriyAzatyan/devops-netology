locals {
   web_instance_type_map = {
      stage = "t3.micro"
      prod = "t3.large"
   }
}

locals {
   web_instance_count_map = {
      stage = 1
      prod = 2
   }
}

locals {
   instances = {
      "t3.micro" = data.aws_ami.latest-ubuntu.id   
      "t3.large" = data.aws_ami.latest-ubuntu.id
    }
}

