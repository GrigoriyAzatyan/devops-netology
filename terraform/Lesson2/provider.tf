terraform {
 backend "s3" {
 key = "~/s3_key" 
 region = "eu-west-2"
 bucket = "test1-gregory78"
 dynamodb_table = "terraform-state-locking"
 }
}

