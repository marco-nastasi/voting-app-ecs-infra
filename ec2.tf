############################
# ALB and Security Groups   #
#############################

# Security Group for the ALB:
resource "aws_security_group" "lb_sg" {
  name        = "${var.app_name}-alb-sg"
  description = "SG for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-alb-sg"
    },
  )
}

# Allow inbound traffic from the internet to the ALB SG on port 80
resource "aws_vpc_security_group_ingress_rule" "allow_port_ingress_alb" {
  for_each          = var.alb_allowed_ports
  security_group_id = aws_security_group.lb_sg.id
  from_port         = each.value
  ip_protocol       = "tcp"
  to_port           = each.value
  cidr_ipv4         = "0.0.0.0/0"
}

# Allow all egress traffic from the ALB SG
resource "aws_vpc_security_group_egress_rule" "allow_all_egress_alb" {
  security_group_id = aws_security_group.lb_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Create an ALB in our public subnet
resource "aws_lb" "alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-alb"
    },
  )
}

# Create a target group for the ALB - vote service
resource "aws_lb_target_group" "alb_tg_vote" {
  name        = "${var.app_name}-alb-tg-1"
  port        = var.vote_container_external_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path              = "/"
    port              = "traffic-port"
    protocol          = "HTTP"
    timeout           = 5
    healthy_threshold = 2
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-alb-tg-1"
    },
  )
}

# Create a target group for the ALB - result service
resource "aws_lb_target_group" "alb_tg_result" {
  name        = "${var.app_name}-alb-tg-2"
  port        = var.result_container_external_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path              = "/"
    port              = "traffic-port"
    protocol          = "HTTP"
    timeout           = 5
    healthy_threshold = 2
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-alb-tg-2"
    },
  )
}

# Listener for the ALB: listens on port 80 and forwards to our target group
resource "aws_lb_listener" "alb_listener_port80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_vote.arn
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-alb-listener-port80"
    },
  )
}

# Listener for the ALB: listens on port 8080 and forwards to our target group
resource "aws_lb_listener" "alb_listener_port8080" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_result.arn
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-alb-listener-port8080"
    },
  )
}