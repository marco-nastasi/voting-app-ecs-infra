

##############################
# These VPC endpoints allow the
# tasks to privately connect to
# ECR/s3/Cloudwatch. 
# We don't need to use NAT Gateways
# and reduce the cost of them.
##############################

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.app_name}-vpc-endpoints"
  description = "SG from ECS tasks to VPC Endpoints"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_ingress" {
  description                  = "Allow ECS tasks to communicate via VPC endpoints"
  security_group_id            = aws_security_group.vpc_endpoints.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_sg.id
}

##############################
# VPC Endpoints
##############################

resource "aws_vpc_endpoint" "vpc_endpoint" {
  for_each            = local.vpc_endpoints_names
  vpc_id              = aws_vpc.main.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids         = [for subnet in aws_subnet.private : subnet.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-${each.key}-endpoint"
    },
  )
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private_table.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-s3-endpoint"
    },
  )
}
