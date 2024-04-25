# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  # This module is only being tested with Terraform 1.0 and newer.
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_organizations_organization" "organization" {}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ OU LEVEL 1
# ---------------------------------------------------------------------------------------------------------------------
locals {
  root_ou_id = data.aws_organizations_organization.organization.roots[0].id
  module_tags = {
    "module_provider" = "ACAI GmbH",
    "module_name"     = "terraform-aws-acf-org-ou-mgmt",
    "module_source"   = "github.com/acai-consulting/terraform-aws-acf-org-ou-mgmt",
    "module_version"  = /*inject_version_start*/ "1.1.0" /*inject_version_end*/
  }

  level_1_ou_transformed = [
    for level_1_ou in var.organizational_units.level1_units :
    {
      parent_id : local.root_ou_id
      path : "/root/${level_1_ou.name}"
      name : level_1_ou.name
      scp_ids : level_1_ou.scp_ids
      tags : merge(level_1_ou.tags, local.module_tags)
      level2_units : level_1_ou.level2_units
    }
  ]
}

resource "aws_organizations_organizational_unit" "level_1_ous" {
  for_each  = { for level_1_ou in local.level_1_ou_transformed : level_1_ou.path => level_1_ou }
  parent_id = each.value.parent_id
  name      = each.value.name
  tags      = each.value.tags
}

locals {
  level_1_ou_scp_attachments = flatten([
    for ou in local.level_1_ou_transformed :
    ou.scp_ids == [] ? [] : [
      for scp_id in ou.scp_ids : {
        "key"     = "${ou.path}:${scp_id}",
        "ou_path" = ou.path,
        "ou_id"   = aws_organizations_organizational_unit.level_1_ous[ou.path].id,
        "scp_id"  = scp_id
      }
    ]
  ])
}

resource "aws_organizations_policy_attachment" "level_1_ous_scp_attachment" {
  for_each = {
    for attachment in local.level_1_ou_scp_attachments :
    attachment.key => {
      target_id = attachment.ou_id,
      policy_id = attachment.scp_id
    }
  }

  target_id = each.value.target_id
  policy_id = each.value.policy_id
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ OU LEVEL 2
# ---------------------------------------------------------------------------------------------------------------------
locals {
  level_2_ou_transformed = flatten([
    for level_1_ou in local.level_1_ou_transformed :
    [
      for level_2_ou in level_1_ou.level2_units :
      {
        parent_id : aws_organizations_organizational_unit.level_1_ous[level_1_ou.path].id
        path : "${level_1_ou.path}/${level_2_ou.name}"
        name : level_2_ou.name
        scp_ids : level_2_ou.scp_ids
        tags : merge(level_2_ou.tags, local.module_tags)
        level3_units : level_2_ou.level3_units
      }
    ]
  ])
}
resource "aws_organizations_organizational_unit" "level_2_ous" {
  for_each  = { for level_2_ou in local.level_2_ou_transformed : level_2_ou.path => level_2_ou }
  parent_id = each.value.parent_id
  name      = each.value.name
  tags      = each.value.tags
}

locals {
  level_2_ou_scp_attachments = flatten([
    for ou in local.level_2_ou_transformed :
    ou.scp_ids == [] ? [] : [
      for scp_id in ou.scp_ids : {
        "key"     = "${ou.path}:${scp_id}",
        "ou_path" = ou.path,
        "ou_id"   = aws_organizations_organizational_unit.level_2_ous[ou.path].id,
        "scp_id"  = scp_id
      }
    ]
  ])
}

resource "aws_organizations_policy_attachment" "level_2_ous_scp_attachment" {
  for_each = {
    for attachment in local.level_2_ou_scp_attachments :
    attachment.key => {
      target_id = attachment.ou_id,
      policy_id = attachment.scp_id
    }
  }

  target_id = each.value.target_id
  policy_id = each.value.policy_id
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ OU LEVEL 3
# ---------------------------------------------------------------------------------------------------------------------
locals {
  level_3_ou_transformed = flatten([
    for level_2_ou in local.level_2_ou_transformed :
    [
      for level_3_ou in level_2_ou.level3_units :
      {
        parent_id : aws_organizations_organizational_unit.level_2_ous[level_2_ou.path].id
        path : "${level_2_ou.path}/${level_3_ou.name}"
        name : level_3_ou.name
        scp_ids : level_3_ou.scp_ids
        tags : merge(level_3_ou.tags, local.module_tags)
        level4_units : level_3_ou.level4_units
      }
    ]
  ])
}

resource "aws_organizations_organizational_unit" "level_3_ous" {
  for_each  = { for level_3_ou in local.level_3_ou_transformed : level_3_ou.path => level_3_ou }
  parent_id = each.value.parent_id
  name      = each.value.name
  tags      = each.value.tags
}

locals {
  level_3_ou_scp_attachments = flatten([
    for ou in local.level_3_ou_transformed :
    ou.scp_ids == [] ? [] : [
      for scp_id in ou.scp_ids : {
        "key"     = "${ou.path}:${scp_id}",
        "ou_path" = ou.path,
        "ou_id"   = aws_organizations_organizational_unit.level_3_ous[ou.path].id,
        "scp_id"  = scp_id
      }
    ]
  ])
}

resource "aws_organizations_policy_attachment" "level_3_ous_scp_attachment" {
  for_each = {
    for attachment in local.level_3_ou_scp_attachments :
    attachment.key => {
      target_id = attachment.ou_id,
      policy_id = attachment.scp_id
    }
  }

  target_id = each.value.target_id
  policy_id = each.value.policy_id
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ OU LEVEL 4
# ---------------------------------------------------------------------------------------------------------------------
locals {
  level_4_ou_transformed = flatten([
    for level_3_ou in local.level_3_ou_transformed :
    [
      for level_4_ou in level_3_ou.level4_units :
      {
        parent_id : aws_organizations_organizational_unit.level_3_ous[level_3_ou.path].id
        path : "${level_3_ou.path}/${level_4_ou.name}"
        name : level_4_ou.name
        scp_ids : level_4_ou.scp_ids
        tags : merge(level_4_ou.tags, local.module_tags)
        level5_units : level_4_ou.level5_units
      }
    ]
  ])
}

resource "aws_organizations_organizational_unit" "level_4_ous" {
  for_each  = { for level_4_ou in local.level_4_ou_transformed : level_4_ou.path => level_4_ou }
  parent_id = each.value.parent_id
  name      = each.value.name
  tags      = each.value.tags
}

locals {
  level_4_ou_scp_attachments = flatten([
    for ou in local.level_4_ou_transformed :
    ou.scp_ids == [] ? [] : [
      for scp_id in ou.scp_ids : {
        "key"     = "${ou.path}:${scp_id}",
        "ou_path" = ou.path,
        "ou_id"   = aws_organizations_organizational_unit.level_4_ous[ou.path].id,
        "scp_id"  = scp_id
      }
    ]
  ])
}

resource "aws_organizations_policy_attachment" "level_4_ous_scp_attachment" {
  for_each = {
    for attachment in local.level_4_ou_scp_attachments :
    attachment.key => {
      target_id = attachment.ou_id,
      policy_id = attachment.scp_id
    }
  }

  target_id = each.value.target_id
  policy_id = each.value.policy_id
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ OU LEVEL 5
# ---------------------------------------------------------------------------------------------------------------------
locals {
  level_5_ou_transformed = flatten([
    for level_4_ou in local.level_4_ou_transformed :
    [
      for level_5_ou in level_4_ou.level5_units :
      {
        parent_id : aws_organizations_organizational_unit.level_4_ous[level_4_ou.path].id
        path : "${level_4_ou.path}/${level_5_ou.name}"
        name : level_5_ou.name
        scp_ids : level_5_ou.scp_ids
        tags : merge(level_5_ou.tags, local.module_tags)
      }
    ]
  ])
}

resource "aws_organizations_organizational_unit" "level_5_ous" {
  for_each  = { for level_5_ou in local.level_5_ou_transformed : level_5_ou.path => level_5_ou }
  parent_id = each.value.parent_id
  name      = each.value.name
  tags      = each.value.tags
}

locals {
  level_5_ou_scp_attachments = flatten([
    for ou in local.level_5_ou_transformed :
    ou.scp_ids == [] ? [] : [
      for scp_id in ou.scp_ids : {
        "key"     = "${ou.path}:${scp_id}",
        "ou_path" = ou.path,
        "ou_id"   = aws_organizations_organizational_unit.level_5_ous[ou.path].id,
        "scp_id"  = scp_id
      }
    ]
  ])
}

resource "aws_organizations_policy_attachment" "level_5_ous_scp_attachment" {
  for_each = {
    for attachment in local.level_5_ou_scp_attachments :
    attachment.key => {
      target_id = attachment.ou_id,
      policy_id = attachment.scp_id
    }
  }

  target_id = each.value.target_id
  policy_id = each.value.policy_id
}
