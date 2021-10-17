output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "user" {
  value = data.aws_caller_identity.current.user_id
}

output "region" {
  value = data.aws_region.current.name
}

output "private_ip" {
  value = aws_instance.ec2.private_ip
}

output "subnet_id" {
  value = aws_instance.ec2.subnet_id
}

