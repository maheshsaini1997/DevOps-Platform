provider "aws" {
  region = "us-east-1"
}

module "vpc" {
    source = "../../modules/vpc"
    environment = "dev"

    vpc_cidr = "10.0.0.0/16"

    public_subnet_cidrs = ["10.0.1.0/24","10.0.2.0/24"]
    private_subnet_cidrs = ["10.0.3.0/24","10.0.4.0/24"]

    availability_zones = [ "us-east-1a", "us-east-1b" ]
  
}

module "ecr" {
    source = "../../modules/ecr"
    environment = "dev"

    repository_names = [
    "user-service",
    "payment-service",
    "notification-service"
  ]
}

module "eks" {
    source = "../../modules/eks"
    environment = "dev"
    cluster_name = "platform"
    vpc_id = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnets
}