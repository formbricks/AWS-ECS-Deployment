locals {
  name   = "dev-core-infra"
  region = "us-east-1"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Environment  = "dev"
  }
}

provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

################################################################################
# ECS Blueprint
################################################################################

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 5.6"
  cluster_name = "ecs_cluster" + local.name
  cluster_service_connect_defaults = {
    namespace = aws_service_discovery_private_dns_namespace.this.arn
  }
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
  tags = local.tags
}

################################################################################
# Service Discovery
################################################################################

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "default.${local.name}.local"
  description = "Service discovery <namespace>.<clustername>.local"
  vpc         = module.vpc.vpc_id
  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name = local.name
  cidr = local.vpc_cidr
  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]
  enable_nat_gateway = true
  single_nat_gateway = false
  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default-network-acl" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default-route-table" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default-security-group" }
  tags = local.tags
}
