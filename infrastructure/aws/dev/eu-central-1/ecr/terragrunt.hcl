include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  root_dir    = dirname(find_in_parent_folders("root.hcl"))
  modules_dir = get_repo_root()
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name        = "img"
}

terraform {
  source = "${local.modules_dir}/infrastructure/modules/terraform-aws-ecr"
}

inputs = {
  name = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"

  tags = local.common_vars.tags
}
