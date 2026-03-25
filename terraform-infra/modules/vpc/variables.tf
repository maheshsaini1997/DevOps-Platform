variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
}

variable "public_subnet_cidrs" {
    description = "List of CIDR blocks for the public subnets"
    type = list(string)
}

variable "private_subnet_cidrs" {
    description = "List of CIDR blocks for the private subnets"
    type = list(string)
}

variable "availability_zones" {
    description = "List of availability zones"
    type = list(string)
}

variable "environment" {
    description = "Environment name (e.g., dev, staging, prod)"
    type = string
}