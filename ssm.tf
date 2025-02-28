resource "aws_ssm_parameter" "ecr_repo_vote_id" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/ecr_repo_vote_id"
  type  = "String"
  value = aws_ecr_repository.vote.arn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-ecr-repo-vote-id"
    },
  )
}

resource "aws_ssm_parameter" "ecr_repo_result_id" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/ecr_repo_result_id"
  type  = "String"
  value = aws_ecr_repository.result.arn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-ecr-repo-result-id"
    },
  )
}

resource "aws_ssm_parameter" "ecr_repo_worker_id" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/ecr_repo_worker_id"
  type  = "String"
  value = aws_ecr_repository.worker.arn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-ecr-repo-worker-id"
    },
  )
}

resource "aws_ssm_parameter" "redis_host_address" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/redis_host_address"
  type  = "String"
  value = aws_elasticache_replication_group.redis_cluster.primary_endpoint_address

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-redis-host-address"
    },
  )
}

resource "aws_ssm_parameter" "postgres_primary_address" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/postgres_primary_address"
  type  = "String"
  value = aws_db_instance.postgres.address

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-postgres-primary-address"
    },
  )
}

resource "aws_ssm_parameter" "postgres_secret_arn" {
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  name  = "/voting-app-ecs/postgres_secret_arn"
  type  = "String"
  value = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:password::"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-postgres-secret-arn"
    },
  )
}

resource "aws_ssm_parameter" "private_subnets_id" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/private_subnets_id"
  type  = "StringList"
  value = jsonencode([for subnet in aws_subnet.private : subnet.id])

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-private-subnets-id"
    },
  )
}

resource "aws_ssm_parameter" "ecs_task_security_group_id" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/ecs_task_security_group_id"
  type  = "String"
  value = aws_security_group.ecs_sg.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-ecs-task-security-group-id"
    },
  )
}

resource "aws_ssm_parameter" "ecs_execution_role_arn" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/ecs_execution_role_arn"
  type  = "String"
  value = aws_iam_role.ecs_task_execution_role.arn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-ecs-execution-role-arn"
    },
  )
}

resource "aws_ssm_parameter" "ecs_task_role_arn" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/ecs_task_role_arn"
  type  = "String"
  value = aws_iam_role.ecs_task_execution_role.arn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-ecs-task-role-arn"
    },
  )
}

resource "aws_ssm_parameter" "ecs_target_group_vote_arn" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/ecs_target_group_vote_arn"
  type  = "String"
  value = aws_lb_target_group.alb_tg_vote.arn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-ecs-target-group-vote-arn"
    },
  )
}

resource "aws_ssm_parameter" "ecs_target_group_result_arn" {
  # checkov:skip=CKV2_AWS_34:This is not sensitive data
  # checkov:skip=CKV_AWS_337:Avoiding usage of KMS CMKs
  name  = "/voting-app-ecs/ecs_target_group_result_arn"
  type  = "String"
  value = aws_lb_target_group.alb_tg_result.arn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ssm-ecs-target-group-result-arn"
    },
  )
}