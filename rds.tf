# Create subnet group for RDS. Include all private subnets
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.app_name}-postgres-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-postgres-subnet-group"
    },
  )
}

# Create security group for RDS
resource "aws_security_group" "postgres" {
  name        = "${var.app_name}-postgres-security-group"
  description = "SG of Postgres RDS DB"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-postgres-security-group"
    },
  )
}

# Create ECS security group ingress rule for Postgres
resource "aws_vpc_security_group_ingress_rule" "postgres_security_group_ingress" {
  description                  = "Allow inbound traffic from the ECS security group"
  security_group_id            = aws_security_group.postgres.id
  referenced_security_group_id = aws_security_group.ecs_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-postgres-security-group-ingress"
    },
  )
}

# Allow all egress traffic from RDS security group
resource "aws_vpc_security_group_egress_rule" "postgres_security_group_egress" {
  description       = "Allow all egress traffic"
  security_group_id = aws_security_group.postgres.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0" # Allow all egress traffic

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-postgres-security-group-egress"
    },
  )
}

# Create RDS instance with 8 GB of storage
resource "aws_db_instance" "postgres" {
  # checkov:skip=CKV_AWS_293:Before moving to prod, enable deletion protection
  # checkov:skip=CKV_AWS_118:Before moving to prod, enable enhanced monitoring
  # checkov:skip=CKV_AWS_161:Consider implementing IAM authentication for RDS
  # checkov:skip=CKV_AWS_353:Before moving to prod, enable performance insights
  # checkov:skip=CKV2_AWS_354:After enabling performance insights, enable encrypt them
  # checkov:skip=CKV2_AWS_30:Before moving to prod, enable query logging
  identifier        = "${var.app_name}-postgres"
  engine            = "postgres"
  engine_version    = "14"
  instance_class    = "db.t4g.micro"
  allocated_storage = 8
  storage_encrypted = true

  # Allow logs to be sent to CloudWatch
  enabled_cloudwatch_logs_exports = ["general", "error", "slowquery"]

  # Database settings
  db_name  = "postgres"
  username = "postgres"

  # Generate a random password for the postgres user
  manage_master_user_password = true

  # Multi-AZ settings to achieve high availability
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  # Backup and maintenance
  backup_retention_period    = 1
  backup_window              = "03:00-04:00"
  maintenance_window         = "Mon:04:00-Mon:05:00"
  auto_minor_version_upgrade = true

  # Additional settings
  publicly_accessible   = false
  skip_final_snapshot   = true
  copy_tags_to_snapshot = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-postgres"
    },
  )
}