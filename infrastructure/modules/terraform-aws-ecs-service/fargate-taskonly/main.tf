resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "${var.namespace}-${var.environment}-${var.app_container_name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

module "app_container_definition" {
  source           = "../container-definition"
  container_name   = "${var.namespace}-${var.environment}-${var.app_container_name}"
  container_image  = var.app_container_image
  container_memory = var.app_container_memory
  container_cpu    = var.app_container_cpu
  environment      = var.app_environment
  secrets          = var.app_secrets
  port_mappings    = var.app_port_mappings
  ulimits          = var.app_ulimits
  command          = var.app_command
  entrypoint       = var.app_entrypoint
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region"        = var.log_region
      "awslogs-group"         = "${var.namespace}-${var.environment}-${var.app_container_name}"
      "awslogs-stream-prefix" = "ecs"
    }
  }
}

resource "aws_ecs_task_definition" "task" {
  family             = "${var.namespace}-${var.environment}-${var.task_name}"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode       = "awsvpc"
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  cpu    = var.task_cpu
  memory = var.task_memory

  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    module.app_container_definition.json_map_object,
  ])

  runtime_platform {
    cpu_architecture = var.cpu_architecture
  }

  tags = var.tags
}

resource "aws_ecs_service" "service" {
  name                               = "${var.namespace}-${var.environment}-${var.task_name}"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.task.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.service_subnets
    security_groups  = var.service_security_groups
    assign_public_ip = var.assign_public_ip
  }

  tags = var.tags
}
