output "task_role_arn" {
  value       = join("", aws_iam_role.ecs_task_role.*.arn)
  description = "ECS Task Role ARN"
}
