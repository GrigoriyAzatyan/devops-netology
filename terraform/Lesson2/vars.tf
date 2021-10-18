variable "instance_options" {

  description = "Instance options"


  type = list(object(
    {
      workspace     = string
      instance_type = string
      replica_count = number
    }
    )
  )

  default = [
    {
      workspace     = "default"
      instance_type = "t2.micro"
      replica_count = 0
    },
    {
      workspace     = "stage"
      instance_type = "t2.micro"
      replica_count = 1
    },
    {
      workspace     = "prod"
      instance_type = "t3.micro"
      replica_count = 2
    }
  ]
}

