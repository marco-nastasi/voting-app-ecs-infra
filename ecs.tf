# Security Group for ECS tasks
resource "aws_security_group" "ecs_sg" {
  # checkov:skip=CKV2_AWS_5:Should remain unattached until the ECS service is created
  name        = "${var.app_name}-ecs-sg"
  description = "SG for ECS tasks"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ecs-sg"
    },
  )
}

# Allow inbound traffic from the ALB SG to the ECS SG
resource "aws_vpc_security_group_ingress_rule" "allow_port_ingress_ecs" {
  for_each                     = var.ecs_allowed_ports
  description                  = "Allow inbound traffic from the ALB SG to the ECS SG on port ${each.value}"
  security_group_id            = aws_security_group.ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = each.value
  to_port                      = each.value
  referenced_security_group_id = aws_security_group.lb_sg.id
}

# Allow all egress traffic from the ECS SG
resource "aws_vpc_security_group_egress_rule" "allow_all_egress_ecs" {
  description       = "Allow all egress traffic from the ECS SG"
  security_group_id = aws_security_group.ecs_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

#############################
# ECS Cluster and IAM Roles #
#############################

# Create an ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  # checkov:skip=CKV_AWS_65:Before moving to prod, enable container insights
  name = "${var.app_name}-ecs-cluster"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ecs-cluster"
    },
  )
}

# Create an IAM Role for ECS task execution (required for pulling container images and logging)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" : data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-ecs-task-execution-role"
    },
  )
}

# Create the IAM policy for CloudWatch Logs and ECS permissions
resource "aws_iam_policy" "ecs_task_policy" {
  # checkov:skip=CKV_AWS_355:Allow ecrGetAuthorizationToken action on "*" resource
  name        = "ecs-task-policy"
  description = "Policy for ECS tasks with CloudWatch Logs permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:*:*:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:ExecuteCommand",
          "ecs:DescribeTasks"
        ]
        Resource = aws_ecs_cluster.cluster.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ],
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_db_instance.postgres.master_user_secret[0].secret_arn
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

resource "aws_ecs_task_definition" "vote_task" {
  # checkov:skip=CKV_AWS_249:Execution and task roles should be different
  # checkov:skip=CKV_AWS_336:App needs root access to FS
  family                   = "voting-app-ecs"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "0"
  memory                   = "256"
  container_definitions = jsonencode([
    {
      name      = "vote"
      image     = "amazon/amazon-ecs-sample"
      cpu       = 0
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        },
      ]
    }
  ])
  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-vote-task"
    },
  )
}

resource "aws_ecs_task_definition" "worker_task" {
  # checkov:skip=CKV_AWS_249:Execution and task roles should be different
  # checkov:skip=CKV_AWS_336:App needs root access to FS
  family                   = "voting-app-ecs"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "0"
  memory                   = "256"
  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = "amazon/amazon-ecs-sample"
      cpu       = 0
      memory    = 256
      essential = true
    }
  ])
  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-vote-task"
    },
  )
}

resource "aws_ecs_task_definition" "result_task" {
  # checkov:skip=CKV_AWS_249:Execution and task roles should be different
  # checkov:skip=CKV_AWS_336:App needs root access to FS
  family                   = "voting-app-ecs"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "0"
  memory                   = "256"
  container_definitions = jsonencode([
    {
      name      = "result"
      image     = "amazon/amazon-ecs-sample"
      cpu       = 0
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
          protocol      = "tcp"
        },
      ]
    }
  ])
  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-vote-task"
    },
  )
}

#############################
# ECS Service               #
#############################

# Create an ECS service to run the task definition.
# The service is associated with the ALB target group so that traffic coming
# into the ALB is forwarded to the "vote" container (port 80).

# Create an ECS service for the vote container
resource "aws_ecs_service" "service_vote" {
  name    = "${var.app_name}-service-vote"
  cluster = aws_ecs_cluster.cluster.id

  task_definition = aws_ecs_task_definition.vote_task.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for subnet in aws_subnet.private : subnet.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg_vote.arn
    container_name   = "placeholder"
    container_port   = var.vote_container_external_port
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-service-vote"
    },
  )
}

# Create an ECS service for the result container
resource "aws_ecs_service" "service_result" {
  name    = "${var.app_name}-service-result"
  cluster = aws_ecs_cluster.cluster.id

  task_definition = aws_ecs_task_definition.result_task.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for subnet in aws_subnet.private : subnet.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg_result.arn
    container_name   = "placeholder"
    container_port   = var.result_container_external_port
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-service-result"
    },
  )
}

resource "aws_ecs_service" "service_worker" {
  name    = "${var.app_name}-service-worker"
  cluster = aws_ecs_cluster.cluster.id

  task_definition = aws_ecs_task_definition.worker_task.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for subnet in aws_subnet.private : subnet.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-service-worker"
    },
  )
}