include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_dir     = dirname(find_in_parent_folders("root.hcl"))
  modules_dir  = get_repo_root()
  common_vars  = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  source_ip    = "3.70.64.111/32"
}

terraform {
  source = "${local.modules_dir}/modules/terraform-aws-security-group"
}

dependency "vpc" {
  config_path = "${local.root_dir}/vpc"
}

inputs = {
  name        = "${local.common_vars.namespace}-${local.common_vars.environment}-ecs-sg"
  description = "Security group for ECS tasks and ALB access"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      description = "Allow HTTP access from ALB"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = local.source_ip
    },
    {
      description = "Allow HTTPS access"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = local.source_ip
    },
    {
      description = "Allow Prometheus UI"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = local.source_ip
    },
    {
      description = "Allow Grafana UI"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = local.source_ip
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound traffic from ECS tasks"
    }
  ]

  tags = local.common_vars.tags
}
