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
  root_ous_paths = { for ou in data.aws_organizations_organizational_units.root_ous.children : ou.id => "/${ou.name}" }
}

data "aws_organizations_organizational_units" "level_1_ous" {
  for_each = { for ou in data.aws_organizations_organizational_units.root_ous.children : "${data.aws_organizations_organization.org.roots[0].id}-${ou.name}" => ou.id }
  parent_id = each.value
}

locals {
  level_1_ous_paths = { for ou_id, ou in data.aws_organizations_organizational_units.level_1_ous : ou.id => "${local.root_ous_paths[ou.parent_id]}/${ou.name}" }
}

data "aws_organizations_organizational_units" "level_2_ous" {
  for_each = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_1_ous : [for child in parent.children : { name = child.name, id = child.id, parent_id = parent.id }]]) : "${ou.parent_id}-${ou.name}" => ou.id }
  parent_id = each.value
}

locals {
  level_2_ous_paths = { for ou_id, ou in data.aws_organizations_organizational_units.level_2_ous : ou.id => "${local.level_1_ous_paths[ou.parent_id]}/${ou.name}" }
}

data "aws_organizations_organizational_units" "level_3_ous" {
  for_each = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_2_ous : [for child in parent.children : { name = child.name, id = child.id, parent_id = parent.id }]]) : "${ou.parent_id}-${ou.name}" => ou.id }
  parent_id = each.value
}

data "aws_organizations_organizational_units" "level_4_ous" {
  for_each = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_3_ous : [for child in parent.children : { name = child.name, id = child.id, parent_id = parent.id }]]) : "${ou.parent_id}-${ou.name}" => ou.id }
  parent_id = each.value
}

data "aws_organizations_organizational_units" "level_5_ous" {
  for_each = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_4_ous : [for child in parent.children : { name = child.name, id = child.id, parent_id = parent.id }]]) : "${ou.parent_id}-${ou.name}" => ou.id }
  parent_id = each.value
}



output "root_ou" {
  value = {
    "/root" = data.aws_organizations_organization.org.roots[0].id
  }
}

output "level_1_ous" {
  value = local.root_ous_paths
}

output "level_2_ous" {
  value = local.level_2_ous_paths
}
