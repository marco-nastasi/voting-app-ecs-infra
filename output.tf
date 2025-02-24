output "ecr_repo_vote_id" {
  value = aws_ecr_repository.vote.arn
}

output "ecr_repo_result_id" {
  value = aws_ecr_repository.result.arn
}

output "ecr_repo_worker_id" {
  value = aws_ecr_repository.worker.arn
}

output "redis-host-address" {
  value = aws_elasticache_replication_group.redis_cluster.primary_endpoint_address
}

output "postgres-primary-address" {
  value = aws_db_instance.postgres.address
}

output "postgres-secret-arn" {
  value = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:password::"
}

output "private-subnets-id" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "ecs-task-security-group-id" {
  value = aws_security_group.ecs_sg.id
}

output "ecs-task-role-arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs-target-group-vote-arn" {
  value = aws_lb_target_group.alb_tg_vote.arn
}

output "ecs-target-group-result-arn" {
  value = aws_lb_target_group.alb_tg_result.arn
}

locals {
  output_data = {
    ecr_repo_vote_id            = aws_ecr_repository.vote.arn
    ecr_repo_result_id          = aws_ecr_repository.result.arn
    ecr_repo_worker_id          = aws_ecr_repository.worker.arn
    redis_host_address          = aws_elasticache_replication_group.redis_cluster.primary_endpoint_address
    postgres_primary_address    = aws_db_instance.postgres.address
    postgres_secret_arn         = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:password::"
    private_subnets_id          = [for subnet in aws_subnet.private : subnet.id]
    ecs_task_security_group_id  = aws_security_group.ecs_sg.id
    ecs_task_role_arn           = aws_iam_role.ecs_task_execution_role.arn
    ecs_target_group_vote_arn   = aws_lb_target_group.alb_tg_vote.arn
    ecs_target_group_result_arn = aws_lb_target_group.alb_tg_result.arn
  }
}

resource "local_file" "outputs" {
  content  = jsonencode(local.output_data)
  filename = "${path.module}/outputs.json"
}

resource "aws_s3_object" "upload_outputs" {
  bucket = var.s3_bucket_outputs_name
  key    = var.s3_bucket_outputs_path
  source = local_file.outputs.filename

  tags = merge(
    var.common_tags,
    {
      Name = "outputs.json"
    },
  )
}