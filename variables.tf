variable "aws_region" {
  type        = string
  description = "AWS Region to deploy the resources"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of VPC"
  default     = "10.255.0.0/16"
}

variable "number_of_availability_zones" {
  type        = number
  description = "Number of availability zones to deploy the resources"
  default     = 2
}

variable "app_name" {
  type        = string
  description = "Name of the app"
  default     = "voting-app-ecs"
}

variable "container_cpu_capacity" {
  type        = string
  description = "Capacity of CPU for ECS tasks"
  default     = "256"
}

variable "container_memory_capacity" {
  type        = string
  description = "Capacity of memory for ECS tasks"
  default     = "512"
}

variable "vote_container_external_port" {
  type        = number
  description = "External port for vote container"
  default     = 8080
}

variable "result_container_external_port" {
  type        = number
  description = "External port for result container"
  default     = 8081
}

variable "number_of_vote_containers" {
  type        = number
  description = "Number of vote containers to run in ECS"
  default     = 1
}

variable "number_of_result_containers" {
  type        = number
  description = "Number of result containers to run in ECS"
  default     = 1
}

variable "number_of_worker_containers" {
  type        = number
  description = "Number of worker containers to run in ECS"
  default     = 1
}

variable "alb_allowed_ports" {
  type        = map(string)
  description = "Allowed ports in the Application Load Balancer"
  default = {
    "port_1" = "80"
    "port_2" = "8080"
  }
}

variable "ecs_allowed_ports" {
  type        = map(string)
  description = "Allowed ports in the ECS tasks"
  default = {
    "port_1" = "8080"
    "port_2" = "8081"
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be added to all resources"
  default = {
    Project   = "voting-app-ecs"
    Terraform = "true"
    Version   = "1.0"
  }
}

locals {
  vpc_endpoints_names = {
    "ecr-dkr"        = "com.amazonaws.${var.aws_region}.ecr.dkr"
    "cloudwatch"     = "com.amazonaws.${var.aws_region}.logs"
    "ecr-api"        = "com.amazonaws.${var.aws_region}.ecr.api"
    "secretsmanager" = "com.amazonaws.${var.aws_region}.secretsmanager"
  }
}