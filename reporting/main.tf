# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.47"
      configuration_aliases = []
    }
  }
}

data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_units" "root_ous" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}
output "root_ou" {
  value = {
    "/root" = data.aws_organizations_organization.org.roots[0].id
  }
}

locals {
  # Map root OUs with their paths
  root_level1_paths = { for ou in data.aws_organizations_organizational_units.root_ous.children : "/root/${ou.name}" => ou.id }
}
output "level_1_ou_paths" {
  value = local.root_level1_paths
}


data "aws_organizations_organizational_units" "level_1_ous" {
  for_each  = { for k, v in local.root_level1_paths : k => v }
  parent_id = each.value
}
output "level_1_ou_childs" {
  value = data.aws_organizations_organizational_units.level_1_ous
}

locals {
  # Assuming data.aws_organizations_organizational_units.level_1_ous simulates structured data similar to your example
  level_1_ous_paths = merge([
    for current_path, ou_data in data.aws_organizations_organizational_units.level_1_ous : {
      for child in ou_data.children : "${current_path}/${child.name}" => child.id
    }
  ]...)
}
output "level_1_ous_paths" {
  value = local.level_1_ous_paths
}
/*
data "aws_organizations_organizational_units" "level_2_ous" {
  for_each  = { for ou in flatten([for parent_id, parent in data.aws_organizations_organizational_units.level_1_ous : [for child in parent.children : { id = child.id, name = child.name, parent_id = parent_id }]]) : ou.id => ou }
  parent_id = each.value.id
}

locals {
  level_2_ous_paths = [] //{ for ou_id, ou in data.aws_organizations_organizational_units.level_2_ous : ou_id => "${local.level_1_ous_paths[ou.parent_id]}/${ou.name}" }
}

data "aws_organizations_organizational_units" "level_3_ous" {
  for_each  = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_2_ous : [for child in parent.children : { name = child.name, id = child.id, parent_id = parent.id }]]) : "${ou.parent_id}-${ou.name}" => ou.id }
  parent_id = each.value
}

data "aws_organizations_organizational_units" "level_4_ous" {
  for_each  = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_3_ous : [for child in parent.children : { name = child.name, id = child.id, parent_id = parent.id }]]) : "${ou.parent_id}-${ou.name}" => ou.id }
  parent_id = each.value
}

data "aws_organizations_organizational_units" "level_5_ous" {
  for_each  = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_4_ous : [for child in parent.children : { name = child.name, id = child.id, parent_id = parent.id }]]) : "${ou.parent_id}-${ou.name}" => ou.id }
  parent_id = each.value
}




output "level_2_ous" {
  value = local.level_2_ous_paths
}
*/