variable "repository_names" {
  description = "List of ECR repositories"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}