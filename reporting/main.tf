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
locals {
  # Assuming data.aws_organizations_organizational_units.level_1_ous simulates structured data similar to your example
  level_0_ous_path = {
    "/root" = data.aws_organizations_organization.org.roots[0].id
  }
}


locals {
  # Map root OUs with their paths
  level_1_ous_paths = { for ou in data.aws_organizations_organizational_units.root_ous.children : "/root/${ou.name}" => ou.id }
}


data "aws_organizations_organizational_units" "level_1_ous" {
  for_each  = { for k, v in local.level_1_ous_paths : k => v }
  parent_id = each.value
}
locals {
  # Assuming data.aws_organizations_organizational_units.level_1_ous simulates structured data similar to your example
  level_2_ous_paths = merge([
    for current_path, ou_data in data.aws_organizations_organizational_units.level_1_ous : {
      for child in ou_data.children : "${current_path}/${child.name}" => child.id
    }
  ]...)
}


data "aws_organizations_organizational_units" "level_2_ous" {
  for_each  = { for k, v in local.level_2_ous_paths : k => v }
  parent_id = each.value
}
locals {
  # Assuming data.aws_organizations_organizational_units.level_1_ous simulates structured data similar to your example
  level_3_ous_paths = merge([
    for current_path, ou_data in data.aws_organizations_organizational_units.level_2_ous : {
      for child in ou_data.children : "${current_path}/${child.name}" => child.id
    }
  ]...)
}


data "aws_organizations_organizational_units" "level_3_ous" {
  for_each  = { for k, v in local.level_3_ous_paths : k => v }
  parent_id = each.value
}
locals {
  # Assuming data.aws_organizations_organizational_units.level_1_ous simulates structured data similar to your example
  level_4_ous_paths = merge([
    for current_path, ou_data in data.aws_organizations_organizational_units.level_3_ous : {
      for child in ou_data.children : "${current_path}/${child.name}" => child.id
    }
  ]...)
}


data "aws_organizations_organizational_units" "level_4_ous" {
  for_each  = { for k, v in local.level_4_ous_paths : k => v }
  parent_id = each.value
}
locals {
  # Assuming data.aws_organizations_organizational_units.level_1_ous simulates structured data similar to your example
  level_5_ous_paths = merge([
    for current_path, ou_data in data.aws_organizations_organizational_units.level_4_ous : {
      for child in ou_data.children : "${current_path}/${child.name}" => child.id
    }
  ]...)
}

