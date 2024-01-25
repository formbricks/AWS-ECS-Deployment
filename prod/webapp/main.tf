terraform {
    cloud {
        organization = "Formbricks"

        workspaces {
            name = "Prod-Webapp-ECS"
        }
    }
}

locals {
    name           = "prod-webapp"
    container_port = 3000
    container_name = "prod-webapp-container"
    tags = {
        Environment = "prod"
    }
}

provider "aws" {
    region = var.region
}

################################################################################
# Supporting Resources
################################################################################

data "aws_vpc" "vpc" {
    filter {
        name   = "tag:Name"
        values = ["prod-core-infra-vpc"]
    }
}

data "aws_subnets" "public" {
    filter {
        name   = "tag:Name"
        values = ["prod-core-infra-vpc-public-*"]
    }
}

data "aws_subnets" "private" {
    filter {
        name   = "tag:Name"
        values = ["prod-core-infra-vpc-private-*"]
    }
}

data "aws_subnet" "private_cidr" {
    for_each = toset(data.aws_subnets.private.ids)
    id       = each.value
}

data "aws_ecs_cluster" "core_infra" {
    cluster_name = "prod-core-infra-ecs-cluster"
}

data "aws_service_discovery_dns_namespace" "this" {
    name = "prod-core-infra-service-discovery-private-dns-namespace"
    type = "DNS_PRIVATE"
}

################################################################################
# ECS Blueprint
################################################################################

module "ecs_service" {
    source  = "terraform-aws-modules/ecs/aws//modules/service"
    version = "~> 5.6"

    name          = "prod-webapp-ecs-service"
    desired_count = 3
    cluster_arn   = data.aws_ecs_cluster.core_infra.arn

    enable_execute_command = false

    # Task Definition IAM Roles
    create_task_exec_iam_role = true
    task_exec_iam_role_name   = "ecsTaskExecRole-prod-webapp-tasks"
    create_task_exec_policy   = true
    task_exec_secret_arns     = values(var.secrets_manager_data)[*]
    task_exec_ssm_param_arns  = []

    container_definitions = {
        (local.container_name) = {
            image                    = "formbricks/formbricks"
            readonly_root_filesystem = false
            port_mappings = [
                {
                    protocol      = "tcp"
                    containerPort = local.container_port
                }
            ]
            secrets = [
                for key, value in var.secrets_manager_data :
                {
                    name      = key
                    valueFrom = "${value}:${key}::"
                }
            ]
            environment = []
        }
    }

    service_registries = {
        registry_arn = aws_service_discovery_service.this.arn
    }

    load_balancer = {
        service = {
            target_group_arn = module.alb.target_groups["ecs-task"].arn
            container_name   = local.container_name
            container_port   = local.container_port
        }
    }

    subnet_ids = data.aws_subnets.private.ids

    security_group_rules = {
        ingress_alb_service = {
            type                     = "ingress"
            from_port                = local.container_port
            to_port                  = local.container_port
            protocol                 = "tcp"
            description              = "Service port"
            source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
            type        = "egress"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    tags = local.tags
}

resource "aws_service_discovery_service" "this" {
    name = "${local.name}-service-discovery"

    dns_config {
        namespace_id = data.aws_service_discovery_dns_namespace.this.id

        dns_records {
            ttl  = 10
            type = "A"
        }

        routing_policy = "MULTIVALUE"
    }

    health_check_custom_config {
        failure_threshold = 1
    }
}

module "alb" {
    source  = "terraform-aws-modules/alb/aws"
    version = "~> 9.0"

    name = "${local.name}-alb"

    # For Prod only
    enable_deletion_protection = true

    vpc_id  = data.aws_vpc.vpc.id
    subnets = data.aws_subnets.public.ids

    security_group_ingress_rules = {
        all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    }

    security_group_egress_rules = {
        for subnet in data.aws_subnet.private_cidr :
        (subnet.availability_zone) => {
            ip_protocol = "-1"
            cidr_ipv4   = subnet.cidr_block
        }
    }

    listeners = {
        https = {
                port            = 443
                protocol        = "HTTPS"
                certificate_arn = var.formbricks_ssl_certificate_arn

            forward = {
                target_group_key = "ecs-task"
            }
        }
    }

    target_groups = {
        ecs-task = {
            backend_protocol = "HTTPS"
            backend_port     = local.container_port
            target_type      = "ip"

            health_check = {
                enabled             = true
                healthy_threshold   = 5
                interval            = 30
                matcher             = "200-299"
                path                = "/"
                port                = "traffic-port"
                protocol            = "HTTP"
                timeout             = 5
                unhealthy_threshold = 2
            }

            # There's nothing to attach here in this definition. Instead,
            # ECS will attach the IPs of the tasks to this target group
            create_attachment = false
        }
    }

    tags = local.tags
}
