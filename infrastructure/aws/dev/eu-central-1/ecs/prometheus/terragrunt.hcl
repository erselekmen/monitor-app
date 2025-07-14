include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_dir       = dirname(find_in_parent_folders("root.hcl"))
  modules_dir    = get_repo_root()
  common_vars    = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name           = "prometheus"
  role_name      = "prometheus-role"
  task_role_name = "prometheus-task-role"
  cpu            = 512
  memory         = 1024
  port           = 9090
}

terraform {
  source = "${local.modules_dir}/infrastructure/modules/terraform-aws-ecs-service//fargate-alb-taskonly"
}

inputs = {
  namespace           = local.common_vars.namespace
  environment         = local.common_vars.environment
  task_name           = local.name
  task_cpu            = local.cpu
  task_memory         = local.memory
  desired_count       = 1

  task_role_name          = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.task_role_name}"
  iam_execution_role_name = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.role_name}"

  cluster_id              = dependency.ecs_cluster.outputs.ecs_cluster_id
  cluster_name            = dependency.ecs_cluster.outputs.ecs_cluster_name
  service_subnets         = dependency.vpc.outputs.private_subnets
  service_security_groups = [dependency.sg_prometheus.outputs.this_security_group_id]

  enable_execute_command = false

  vpc_id                    = dependency.vpc.outputs.vpc_id
  internal_listener_enabled = false
  aws_lb_listener_arn       = dependency.alb_external.outputs.http_listener_arns[0]
  path_routing              = ["/prometheus"]
  health_check_path         = "/"
  health_check_protocol     = "HTTP"
  tg_protocol               = "HTTP"
  health_check_matcher      = 200

  log_region            = local.common_vars.region
  log_retention_in_days = 30

  app_container_port   = local.port
  app_container_name   = "${local.name}"
  app_container_image  = "${dependency.ecr_monitor.outputs.repository_url}:prometheus-latest"
  app_container_cpu    = local.cpu
  app_container_memory = local.memory
  app_port_mappings = [
    {
      containerPort = local.port
      hostPort      = local.port
      protocol      = "tcp"
    }
  ]

  tags = local.common_vars.tags
}

dependency "vpc" {
  config_path = "${local.root_dir}/vpc"
}

dependency "ecs_cluster" {
  config_path = "${local.root_dir}/terraform-aws-ecs-cluster"
}

dependency "ecr_monitor" {
  config_path = "${local.root_dir}/terraform-aws-ecr"
}

dependency "sg_web" {
  config_path = "${local.root_dir}/terraform-aws-security-group"
}

dependency "alb_external" {
  config_path = "${local.root_dir}/terraform-aws-alb"
}
