include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_dir    = dirname(find_in_parent_folders("root.hcl"))
  modules_dir = get_repo_root()
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name        = "ecs-sg"
}

terraform {
  source = "${local.modules_dir}/infrastructure/modules/terraform-aws-security-group"
}

inputs = {
  name        = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  description = "Security group for Monitor App ECS Service"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 9090
      to_port                  = 9090
      protocol                 = "tcp"
      description              = "HTTP access from External ALB"
      source_security_group_id = dependency.sg_alb_external.outputs.this_security_group_id
    },
    {
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      description              = "HTTP access from External ALB"
      source_security_group_id = dependency.sg_alb_external.outputs.this_security_group_id
    },
    {
      from_port                = 5000
      to_port                  = 5000
      protocol                 = "tcp"
      description              = "HTTP access from External ALB"
      source_security_group_id = dependency.sg_alb_external.outputs.this_security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound connections"
    }
  ]

  tags = local.common_vars.tags
}

dependency "vpc" {
  config_path = "${local.root_dir}/vpc"
}

dependency "sg_alb_external" {
  config_path = "${local.root_dir}/sg/alb/external"
}
