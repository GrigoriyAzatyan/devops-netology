# В уже созданный aws_instance добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах использовались разные instance_type:

resource "aws_instance" "ec2-2" {
   ami = data.aws_ami.latest-ubuntu.id
   instance_type = local.web_instance_type_map[terraform.workspace]
   key_name = "my-key"
   tags = {
     Name = "EC2 - two workspaces"
   }
}


# Добавим count. Для stage должен создаться один экземпляр ec2, а для prod два:

resource "aws_instance" "ec2-3" {
   ami = data.aws_ami.latest-ubuntu.id 
   instance_type = local.web_instance_type_map[terraform.workspace]
   count = local.web_instance_count_map[terraform.workspace]
   key_name = "my-key"
   tags = {
     Name = "EC2 - two workspaces"
   }
}


# Создайте рядом еще один aws_instance, но теперь определите их количество при помощи for_each, а не count:

resource "aws_instance" "ec2-4" {
  for_each = { for option in var.instance_options : option.replica_count => option }
  ami = data.aws_ami.latest-ubuntu.id 
  instance_type = "each.key.instance_type"
  tags = {
    Name = "{each.key.workspace}-{index(var.instance_options, each.key)}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

