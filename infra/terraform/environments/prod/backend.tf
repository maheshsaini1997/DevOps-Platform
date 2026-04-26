terraform {
  backend "s3" {
    bucket = "mahesh-terraform-state-530467655811"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
    
  }
}