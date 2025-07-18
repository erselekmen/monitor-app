resource "aws_lb_target_group" "lb_tg" {
  name                 = var.target_group_name
  port                 = var.nginx_container_port
  protocol             = "HTTPS"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  tags                 = var.tags
  deregistration_delay = var.deregistration_delay

  health_check {
    protocol            = var.health_check_protocol
    path                = var.health_check_path
    interval            = var.health_check_interval
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  stickiness {
    enabled         = var.stickiness_enabled
    cookie_duration = var.stickiness_cookie_duration
    type            = var.stickiness_type
  }
}

resource "aws_lb_listener_rule" "lb_rule" {
  count    = length(var.path_routing) == 0 ? 1 : 0
  priority = var.priority

  listener_arn = var.aws_lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }

  condition {
    host_header {
      values = var.host_headers
    }
  }
}

resource "aws_lb_listener_rule" "path_lb_rule" {
  count    = length(var.path_routing) == 0 ? 0 : 1
  priority = var.priority

  listener_arn = var.aws_lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }

  condition {
    host_header {
      values = var.host_headers
    }
  }

  condition {
    path_pattern {
      values = var.path_routing
    }
  }
}

resource "aws_lb_target_group" "lb_tg_internal" {
  count                = var.internal_listener_enabled ? 1 : 0
  name                 = "${var.target_group_name}-internal"
  port                 = var.nginx_container_port
  protocol             = "HTTPS"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  tags                 = var.tags
  deregistration_delay = var.deregistration_delay_internal

  health_check {
    protocol            = var.health_check_protocol
    path                = var.health_check_path
    interval            = var.health_check_interval
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  stickiness {
    enabled         = var.stickiness_enabled
    cookie_duration = var.stickiness_cookie_duration
    type            = var.stickiness_type
  }
}

resource "aws_lb_listener_rule" "lb_rule_internal" {
  count        = var.internal_listener_enabled ? 1 : 0
  listener_arn = var.aws_lb_internal_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg_internal[0].arn
  }

  condition {
    host_header {
      values = var.internal_host_headers
    }
  }
}

##
resource "aws_lb_target_group" "lb_tg_internal_coop" {
  count                = var.internal_coop_listener_enabled ? 1 : 0
  name                 = "${var.target_group_name}-int-coop"
  port                 = var.nginx_container_port
  protocol             = "HTTPS"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  tags                 = var.tags
  deregistration_delay = var.deregistration_delay_coop

  health_check {
    protocol            = var.health_check_protocol
    path                = var.health_check_path
    interval            = var.health_check_interval
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  stickiness {
    enabled         = var.stickiness_enabled
    cookie_duration = var.stickiness_cookie_duration
    type            = var.stickiness_type
  }
}

resource "aws_lb_listener_rule" "lb_rule_internal_coop" {
  count        = var.internal_coop_listener_enabled ? 1 : 0
  listener_arn = var.aws_lb_internal_coop_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg_internal_coop[0].arn
  }

  condition {
    host_header {
      values = var.internal_coop_host_headers
    }
  }
}
##

resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "${var.namespace}-${var.environment}-${var.app_container_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "nginx_log_group" {
  name              = "${var.namespace}-${var.environment}-${var.nginx_container_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_subscription_filter" "app_log_subscription_filter" {
  count           = var.log_destination_arn == "" ? 0 : 1
  name            = "${var.namespace}-${var.environment}-${var.app_container_name}"
  log_group_name  = "${var.namespace}-${var.environment}-${var.app_container_name}"
  filter_pattern  = ""
  destination_arn = var.log_destination_arn
}

resource "aws_cloudwatch_log_subscription_filter" "nginx_log_subscription_filter" {
  count           = var.log_destination_arn == "" ? 0 : 1
  name            = "${var.namespace}-${var.environment}-${var.nginx_container_name}"
  log_group_name  = "${var.namespace}-${var.environment}-${var.nginx_container_name}"
  filter_pattern  = ""
  destination_arn = var.log_destination_arn
}

module "app_container_definition" {
  source           = "/Users/ersel.ekmen/Documents/GitHub/monitor-app/infrastructure/modules/terraform-aws-ecs-service/container-definition"
  container_name   = "${var.namespace}-${var.environment}-${var.app_container_name}"
  container_image  = var.app_container_image
  container_memory = var.app_container_memory
  container_cpu    = var.app_container_cpu
  environment      = var.app_environment
  secrets          = var.app_secrets
  port_mappings    = var.app_port_mappings
  ulimits          = var.app_ulimits
  command          = var.app_command
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = var.log_region
      "awslogs-group"         = "${var.namespace}-${var.environment}-${var.app_container_name}"
      "awslogs-stream-prefix" = "ecs"
    }
  }
  mount_points = length(var.volumes) == 0 ? [] : [
    for mount_point in var.volumes : {
      containerPath = lookup(mount_point, "container_path")
      sourceVolume  = lookup(mount_point, "name")
    }
  ]
}

module "nginx_container_definition" {
  source           = "/Users/ersel.ekmen/Documents/GitHub/monitor-app/infrastructure/modules/terraform-aws-ecs-service/container-definition"
  container_name   = "${var.namespace}-${var.environment}-${var.nginx_container_name}"
  container_image  = var.nginx_container_image
  container_memory = var.nginx_container_memory
  container_cpu    = var.nginx_container_cpu
  environment      = var.nginx_environment
  port_mappings    = var.nginx_port_mappings
  ulimits          = var.nginx_ulimits
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = var.log_region
      "awslogs-group"         = "${var.namespace}-${var.environment}-${var.nginx_container_name}"
      "awslogs-stream-prefix" = "ecs"
    }
  }
}

resource "aws_ecs_task_definition" "task" {
  family             = "${var.namespace}-${var.environment}-${var.task_name}"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  network_mode       = "awsvpc"

  cpu    = var.task_cpu
  memory = var.task_memory

  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    module.app_container_definition.json_map_object,
    module.nginx_container_definition.json_map_object
  ])

  dynamic "volume" {
    for_each = length(var.volumes) == 0 ? [] : var.volumes

    content {
      name = lookup(volume.value, "name", null)
      efs_volume_configuration {
        root_directory = lookup(volume.value, "root_directory", null)
        file_system_id = lookup(volume.value, "file_system_id", null)
      }
    }
  }

  tags = var.tags
}

resource "aws_ecs_service" "service" {
  name                               = "${var.namespace}-${var.environment}-${var.task_name}"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.task.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = var.deployment_maximum_percent != "" ? var.deployment_maximum_percent : "200"
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent != "" ? var.deployment_minimum_healthy_percent : "100"
  enable_execute_command             = var.enable_execute_command

  network_configuration {
    subnets          = var.service_subnets
    security_groups  = var.service_security_groups
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = "${var.namespace}-${var.environment}-${var.nginx_container_name}"
    container_port   = var.nginx_container_port
  }

  dynamic "load_balancer" {
    for_each = var.internal_listener_enabled ? aws_lb_target_group.lb_tg_internal.*.arn : []

    content {
      target_group_arn = load_balancer.value
      container_name   = "${var.namespace}-${var.environment}-${var.nginx_container_name}"
      container_port   = var.nginx_container_port
    }
  }

  dynamic "load_balancer" {
    for_each = var.internal_coop_listener_enabled ? aws_lb_target_group.lb_tg_internal_coop.*.arn : []

    content {
      target_group_arn = load_balancer.value
      container_name   = "${var.namespace}-${var.environment}-${var.nginx_container_name}"
      container_port   = var.nginx_container_port
    }
  }

  tags = var.tags
}
