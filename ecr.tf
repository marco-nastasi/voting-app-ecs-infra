# ECR repository to push the vote container image
resource "aws_ecr_repository" "vote" {
  name                 = "ecr-repo-vote"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ecr-repo-vote"
    },
  )
}

# ECR repository to push the result container image
resource "aws_ecr_repository" "result" {
  name                 = "ecr-repo-result"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ecr-repo-result"
    },
  )
}

# ECR repository to push the worker container image
resource "aws_ecr_repository" "worker" {
  name                 = "ecr-repo-worker"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ecr-repo-worker"
    },
  )
}