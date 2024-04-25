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

data "aws_organizations_organizational_units" "level_1_ous" {
  for_each = { for ou in data.aws_organizations_organizational_units.root_ous.children : "/root/${ou.name}" => ou.id }
  parent_id = each.value
}

data "aws_organizations_organizational_units" "level_2_ous" {
  for_each = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_1_ous : parent.children]) : "/root/${parent.name}/${ou.name}" => ou.id }
  parent_id = each.value
}

data "aws_organizations_organizational_units" "level_3_ous" {
  for_each = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_2_ous : parent.children]) : ou.name => ou.id }
  parent_id = each.value
}

data "aws_organizations_organizational_units" "level_4_ous" {
  for_each = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_3_ous : parent.children]) : ou.name => ou.id }
  parent_id = each.value
}

data "aws_organizations_organizational_units" "level_5_ous" {
  for_each = { for ou in flatten([for parent in data.aws_organizations_organizational_units.level_4_ous : parent.children]) : ou.name => ou.id }
  parent_id = each.value
}


/*
data "aws_organizations_organizational_units" "level_2_ous" {
  count     = length(data.aws_organizations_organizational_units.level_1_ous.children)
  parent_id = data.aws_organizations_organizational_units.level_1_ous.children[count.index].id
}
/*

data "aws_organizations_organizational_units" "level_3_ous" {
  count     = length(data.aws_organizations_organizational_units.level_2_ous.children)
  parent_id = data.aws_organizations_organizational_units.level_2_ous.children[count.index].id
}


data "aws_organizations_organizational_units" "level_4_ous" {
  count     = length(data.aws_organizations_organizational_units.level_3_ous.children)
  parent_id = data.aws_organizations_organizational_units.level_3_ous.children[count.index].id
}


data "aws_organizations_organizational_units" "level_5_ous" {
  count     = length(data.aws_organizations_organizational_units.level_4_ous.children)
  parent_id = data.aws_organizations_organizational_units.level_4_ous.children[count.index].id
}

*/
output "root_ou" {
  value = {
    "/root" = data.aws_organizations_organization.org.roots[0].id
  }
}

output "level_1_ous" {
  value = data.aws_organizations_organizational_units.level_1_ous
}

output "level_2_ous" {
  value = data.aws_organizations_organizational_units.level_2_ous
}
