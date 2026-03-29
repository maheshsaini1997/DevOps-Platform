resource "aws_ecr_repository" "repos" {
  count = length(var.repository_names)
  name = "${var.environment}-${var.repository_names[count.index]}"
  force_delete = true
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}