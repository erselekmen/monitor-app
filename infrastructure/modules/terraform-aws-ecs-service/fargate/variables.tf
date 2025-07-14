variable "namespace" {
  type = string
}

variable "environment" {
  type = string
}

variable "task_name" {
  type = string
}

variable "task_cpu" {
  type = number
}

variable "task_memory" {
  type = number
}

variable "cluster_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "scaling_enabled" {
  type    = bool
  default = false
}

variable "min_capacity" {
  type    = number
  default = 2
}

variable "max_capacity" {
  type    = number
  default = 4
}

variable "target_memory" {
  type    = number
  default = 80
}

variable "target_cpu" {
  type    = number
  default = 80
}

variable "service_subnets" {
  type = list(string)
}

variable "service_security_groups" {
  type = list(string)
}

variable "health_check_path" {
  type = string
}

variable "health_check_protocol" {
  type = string
}

variable "health_check_interval" {
  type    = number
  default = 30
}

variable "health_check_unhealthy_threshold" {
  type    = number
  default = 3
}

variable "iam_execution_role_name" {
  type = string
}

variable "task_role_name" {
  type = string
}

variable "task_policies" {
  type    = list(string)
  default = []
}

variable "secret_arns" {
  type = list(string)
}

variable "target_group_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "aws_lb_listener_arn" {
  type = string
}

variable "host_headers" {
  type = list(string)
}

variable "path_routing" {
  type    = list(string)
  default = []
}

variable "internal_listener_enabled" {
  type    = bool
  default = false
}

variable "aws_lb_internal_listener_arn" {
  type    = string
  default = ""
}

variable "internal_host_headers" {
  type    = list(string)
  default = []
}

variable "internal_coop_listener_enabled" {
  type    = bool
  default = false
}

variable "aws_lb_internal_coop_listener_arn" {
  type    = string
  default = ""
}

variable "internal_coop_host_headers" {
  type    = list(string)
  default = []
}

variable "log_region" {
  type = string
}

variable "log_retention_in_days" {
  type = number
}

variable "log_destination_arn" {
  type    = string
  default = ""
}

variable "app_container_name" {
  type        = string
  description = "The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, _ allowed)"
}

variable "app_container_image" {
  type        = string
  description = "The image used to start the container. Images in the Docker Hub registry available by default"
}

variable "app_container_memory" {
  type        = number
  description = "The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  default     = null
}

variable "app_container_cpu" {
  type        = number
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
  default     = 0
}

variable "app_ulimits" {
  type = list(object({
    name      = string
    softLimit = number
    hardLimit = number
  }))

  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

  default = []
}

variable "app_command" {
  type    = list(string)
  default = []
}

variable "app_environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "The environment variables to pass to the container. This is a list of maps. map_environment overrides environment"
  default     = []
}

variable "app_secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "The secret variables to pass to the container. This is a list of maps. map_environment overrides environment"
  default     = []
}

variable "app_port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

  default = []
}

variable "nginx_container_name" {
  type        = string
  description = "The name of the container. Up to 255 characters ([a-z], [A-Z], [0-9], -, _ allowed)"
}

variable "nginx_container_image" {
  type        = string
  description = "The image used to start the container. Images in the Docker Hub registry available by default"
}

variable "nginx_container_memory" {
  type        = number
  description = "The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  default     = null
}

variable "nginx_container_cpu" {
  type        = number
  description = "The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
  default     = 0
}

variable "nginx_environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "The environment variables to pass to the container. This is a list of maps. map_environment overrides environment"
  default     = []
}

variable "nginx_port_mappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))

  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

  default = []
}

variable "nginx_ulimits" {
  type = list(object({
    name      = string
    softLimit = number
    hardLimit = number
  }))

  description = "The port mappings to configure for the container. This is a list of maps. Each map should contain \"containerPort\", \"hostPort\", and \"protocol\", where \"protocol\" is one of \"tcp\" or \"udp\". If using containers in a task with the awsvpc or host network mode, the hostPort can either be left blank or set to the same value as the containerPort"

  default = []
}

variable "nginx_container_port" {
  type = number
}

variable "stickiness_enabled" {
  type    = bool
  default = false
}

variable "stickiness_cookie_duration" {
  type        = number
  description = "Default value is 1 day (in seconds)"
  default     = 86400
}

variable "stickiness_type" {
  type    = string
  default = "lb_cookie"
}

variable "volumes" {
  type    = list(map(string))
  default = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}

variable "priority" {
  type    = number
  default = null
}

variable "deployment_minimum_healthy_percent" {
  type    = number
  default = 100
}

variable "deployment_maximum_percent" {
  type    = number
  default = 200
}

variable "deregistration_delay" {
  type    = number
  default = 300
}

variable "deregistration_delay_internal" {
  type    = number
  default = 300
}

variable "deregistration_delay_coop" {
  type    = number
  default = 300
}

variable "enable_execute_command" {
  type = bool
  default = false
}