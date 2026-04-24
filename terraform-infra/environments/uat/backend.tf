terraform {
  backend "s3" {
    bucket = "mahesh-terraform-state"
    key    = "uat/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
    
  }
}