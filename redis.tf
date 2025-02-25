# Create ElastiCache Subnet Group. Include all private subnets
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-redis-subnet-group"
    },
  )
}

# Create ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "redis_parameter_group" {
  family = "redis6.x"
  name   = "${var.app_name}-redis-parameter-group"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-redis-parameter-group"
    },
  )

}

# Create Security Group for ElastiCache.
# Allow inbound traffic from the ECS security group
# and allow all egress traffic
resource "aws_security_group" "redis_security_group" {
  name        = "redis-security-group"
  description = "SG of Redis cluster"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-redis-security-group"
    },
  )
}

# Create ECS security group ingress rule for Redis
resource "aws_vpc_security_group_ingress_rule" "redis_security_group_ingress" {
  description                  = "Allow inbound traffic from the ECS security group"
  security_group_id            = aws_security_group.redis_security_group.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_sg.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-redis-security-group-ingress"
    },
  )
}

# Create ElastiCache security group egress rule for all traffic
resource "aws_vpc_security_group_egress_rule" "redis_security_group_egress" {
  description       = "Allow all egress traffic"
  security_group_id = aws_security_group.redis_security_group.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-redis-security-group-egress"
    },
  )
}

# Create ElastiCache Replication Group to achieve high availability
resource "aws_elasticache_replication_group" "redis_cluster" {
  # checkov:skip=CKV_AWS_29:Before moving to prod, enable encryption at rest
  # checkov:skip=CKV_AWS_30:Before moving to prod, encrypt all data in transit
  # checkov:skip=CKV_AWS_31:Before moving to prod, enable encryption in transit
  # checkov:skip=CKV_AWS_191:Before moving to prod, encrypt using KMS
  description          = "${var.app_name} Redis cluster"
  replication_group_id = "${var.app_name}-redis-cluster"
  node_type            = "cache.t2.micro"
  port                 = 6379
  parameter_group_name = aws_elasticache_parameter_group.redis_parameter_group.name
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.redis_security_group.id]

  # Enable Multi-AZ
  automatic_failover_enabled = true
  multi_az_enabled           = true

  # Number of replica nodes
  num_cache_clusters = 2

  # Redis settings
  engine         = "redis"
  engine_version = "6.x"

  # Maintenance window
  maintenance_window = "sun:05:00-sun:06:00"

  # Backup settings
  snapshot_retention_limit = 1
  snapshot_window          = "00:00-01:00"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-redis-cluster"
    },
  )
}