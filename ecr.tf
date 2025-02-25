# ECR repository to push the vote container image
resource "aws_ecr_repository" "vote" {
  # checkov:skip=CKV2_AWS_136: Encrypt all ECR repos using KMS
  # checkov:skip=CKV2_AWS_163: Image scanning on push should be enabled
  name                 = "ecr-repo-vote"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

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
  # checkov:skip=CKV2_AWS_136: Encrypt all ECR repos using KMS
  # checkov:skip=CKV2_AWS_163: Image scanning on push should be enabled
  name                 = "ecr-repo-result"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

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
  # checkov:skip=CKV2_AWS_136: Encrypt all ECR repos using KMS
  # checkov:skip=CKV2_AWS_163: Image scanning on push should be enabled
  name                 = "ecr-repo-worker"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

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