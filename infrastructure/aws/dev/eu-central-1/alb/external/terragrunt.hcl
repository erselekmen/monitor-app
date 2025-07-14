include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_dir    = dirname(find_in_parent_folders("root.hcl"))
  modules_dir = get_repo_root()
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name        = "external"
  type        = "application"
}

terraform {
  source = "${local.modules_dir}/infrastructure/modules/terraform-aws-alb"
}

inputs = {
  name               = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  load_balancer_type = local.type
  internal           = false

  vpc_id          = dependency.vpc.outputs.vpc_id
  subnets         = dependency.vpc.outputs.public_subnet_ids
  security_groups = [dependency.sg_alb_external.outputs.this_security_group_id]

  enable_deletion_protection = false

  http_tcp_listeners = [
    {
      port         = 80
      protocol     = "HTTP"
      action_type  = "forward"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix         = "def"
      backend_protocol    = "HTTP"
      backend_port        = 8080
      target_type         = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        path                = "/"
        matcher             = "200"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
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
