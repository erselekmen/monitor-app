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

variable "service_subnets" {
  type = list(string)
}

variable "service_security_groups" {
  type = list(string)
}

variable "iam_execution_role_name" {
  type = string
}

variable "secret_arns" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "log_region" {
  type = string
}

variable "log_retention_in_days" {
  type = number
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

variable "app_entrypoint" {
  type        = list(string)
  description = "The entrypoint that container will use to start."
  default     = [""]
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

variable "task_role_name" {
  type = string
}

variable "task_policies" {
  type    = list(string)
  default = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}

variable "deployment_maximum_percent" {
  type    = number
  default = 200
}

variable "deployment_minimum_healthy_percent" {
  type    = number
  default = 100
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "cpu_architecture" {
  type    = string
  default = "X86_64"
}
