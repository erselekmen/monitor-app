include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_dir           = dirname(find_in_parent_folders("root.hcl"))
  modules_dir        = get_repo_root()
  common_vars        = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name               = "cluster"
  container_insights = true
  capacity_providers = ["FARGATE"]
}

terraform {
  source = "${local.modules_dir}/infrastructure/modules/terraform-aws-ecs-cluster"
}

inputs = {
  cluster_name               = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  container_insights = local.container_insights

  capacity_providers = local.capacity_providers
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
    }
  ]

  tags = local.common_vars.tags
}
