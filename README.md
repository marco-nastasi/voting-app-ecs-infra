# Voting App ECS Deployment

This repository provides a modular and secure Terraform configuration to deploy a voting application on AWS ECS. The project is divided into multiple files for a clear separation of concerns and easy maintainability.

## Table of Contents

- [Overview](#overview)
- [Security](#security)
- [Modularity](#modularity)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview

This Terraform project automates the deployment of a voting application with the following core components:
- **AWS ECS Cluster** for container orchestration ([ecs.tf](ecs.tf))
- **ECR Repositories** for container images ([ecr.tf](ecr.tf))
- **Application Load Balancer (ALB)** to allow access from internet without exposing the infrastructure to the internet ([ec2.tf](ec2.tf))
- **RDS Postgres database** as a managed database solution ([rds.tf](rds.tf))
- **Redis with ElastiCache** as a managed caching solution([redis.tf](redis.tf))
- **VPC and Networking** for isolated network resources ([vpc.tf](vpc.tf) and [vpc_endpoints.tf](vpc_endpoints.tf))

## Security

Security is a top priority in this project:
- **IAM Roles and Policies:** The [ecs.tf](ecs.tf) file creates dedicated IAM roles and policies for ECS tasks ensuring least privilege by granting only the necessary permissions.
- **Encryption:** ECR repositories are configured with encryption ([ecr.tf](ecr.tf)). RDS and ElastiCache setups incorporate encryption and secure parameter configurations.
- **Security Groups:** All network traffic is strictly controlled using security groups and ingress/egress rules defined in [ec2.tf](ec2.tf), [ecs.tf](ecs.tf), and [redis.tf](redis.tf).
- **Private Networking:** The use of VPC endpoints ([vpc_endpoints.tf](vpc_endpoints.tf)) and private subnets ([vpc.tf](vpc.tf)) ensures secure private access to AWS services such as S3, ECR, and CloudWatch.
- **Automated Scans:** Security scans using Checkov are integrated with GitHub Actions workflows ([.github/workflows/terraform-plan.yml](.github/workflows/terraform-plan.yml)).

## Modularity

The project is structured into distinct modules/files that address various parts of the infrastructure:
- **Core Networking:** `vpc.tf` handles VPC, subnets, Internet Gateway, and route tables.
- **Container Infrastructure:** `ecs.tf` sets up the ECS cluster, security groups, and IAM roles for tasks.
- **Data Stores:** `rds.tf` and `redis.tf` create and configure the Postgres database and Redis cache.
- **ECR Repositories:** `ecr.tf` provisions dedicated ECR repositories for vote, result, and worker container images.
- **Backend Configuration:** `backend.tf` and `terraform.tf` manage the Terraform state and provider setup.
- **Workflow Integration:** GitHub Actions workflows under [`.github/workflows`](.github/workflows/) ensure continuous integration, linting, and secure deployment practices.

This modular approach allows teams to update and manage individual components independently while ensuring reusability and clarity.

## Usage

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.10
- AWS account with necessary permissions. To avoid using static credentials such as AWS Access Keys, Open ID Connect is used.

### Preparation steps

There are five preparation steps, all defined in the Github Action workflow: **1 - Prepare Terraform plan**. This workflow will run automatically after a Pull Request is merged to "main" and can also be run manually on demand.

- Terraform format check: Formats your Terraform configuration files into a canonical format and style. It uses the `terraform fmt` CLI command.
- Validate Terraform code: Verifies the correctness of Terraform configuration files. It uses the `terraform validate` CLI command.
- Lint Terraform code: Uses a linter (tflint) that checks for possible errors in the code.
- Security Scan: Uses checkov to perform security scans and identify issues before deploying to AWS.
- Create Terraform plan: Creates a plan with actions to take the infrastructure to the desired state. The state file is considered a sensitive artifact, this is why is not stored in Github but in a private S3 bucket in AWS.

### Deployment to AWS

There are two steps, all defined in the Github Action workflow: **2 - Deploy Plan to AWS**. This workflow will run on demand, it will not run automatically.

- Check if valid plan exists: Checks that the previous workflow was executed successfully for the current commit SHA.
- Terraform Apply: Downloads the plan stored in the S3 bucket and applies it.

### Decommission resources

There is one step in the workflow: **3 - Remove from AWS**. This workflow will run on demand, it will not run automatically.

- Terraform Destroy: Removes all infrastructure declared in this project. It uses `terraform destroy`.