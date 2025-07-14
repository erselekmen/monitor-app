locals {
  base_task_policies = var.task_policies
  ssm_policies = var.enable_execute_command ? [
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
    "arn:aws:iam::aws:policy/AWSCloud9SSMInstanceProfile"
  ] : []
  all_task_policies = concat(local.base_task_policies, local.ssm_policies)
}

resource "aws_iam_role" "ecs_task_role" {
  name               = var.task_role_name
  assume_role_policy = file("../files/ecs_task_execution_role.json")
}

resource "aws_iam_role_policy_attachment" "task_policy_attachment" {
  count      = length(local.all_task_policies)
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = local.all_task_policies[count.index]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.iam_execution_role_name
  assume_role_policy = file("../files/ecs_task_execution_role.json")
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "secrets_manager_policy" {
  count       = length(var.secret_arns) > 0 ? 1 : 0
  name        = var.iam_execution_role_name
  path        = "/"
  description = "ECS task execution role policy to access secrets manager"
  policy      = data.aws_iam_policy_document.secrets_manager_policy_document.json
}

data "aws_iam_policy_document" "secrets_manager_policy_document" {
  statement {
    sid = ""

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = var.secret_arns
  }
}

resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  count      = length(var.secret_arns) > 0 ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy[0].arn
}
