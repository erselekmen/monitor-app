include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_dir        = dirname(find_in_parent_folders("root.hcl"))
  modules_dir     = get_repo_root()
  common_vars     = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name            = "external"
  type            = "application"
  security_policy = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

terraform {
  source = "${local.modules_dir}/modules/terraform-aws-alb"
}

inputs = {

  name               = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  load_balancer_type = local.type
  internal           = false

  vpc_id          = dependency.vpc.outputs.vpc_id
  subnets         = dependency.vpc.outputs.public_subnets
  security_groups = [dependency.sg_alb_external.outputs.this_security_group_id]

  enable_deletion_protection  = true
  listener_ssl_policy_default = local.security_policy

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = local.common_vars.certificate_arn
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Default root"
        status_code  = "400"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
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
