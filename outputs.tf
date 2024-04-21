output "organization_id" {
  value       = data.aws_organizations_organization.organization.id
  description = "The ID of the AWS Organization."
}

output "root_ou_id" {
  value       = tolist(data.aws_organizations_organization.organization.roots)[0].id
  description = "The ID of the root organizational unit."
}

output "ou_transformed" {
  description = "List of transformed OUs."
  value = [
    local.level_1_ou_transformed,
    local.level_2_ou_transformed,
    local.level_3_ou_transformed,
    local.level_4_ou_transformed,
    local.level_5_ou_transformed
  ]
}

output "ou_scp_assignment" {
  description = "SCP assignments."
  value = [
    local.level_1_ou_scp_attachments,
    local.level_2_ou_scp_attachments,
    local.level_3_ou_scp_attachments,
    local.level_4_ou_scp_attachments,
    local.level_5_ou_scp_attachments,
  ]
}

output "organizational_units_paths_ids" {
  description = "Map of full OU-Path and OU-ID."
  value = merge(
    {
      "/root" = local.root_ou_id
    },
    { for path, ou in aws_organizations_organizational_unit.level_1_ous : path => ou.id },
    { for path, ou in aws_organizations_organizational_unit.level_2_ous : path => ou.id },
    { for path, ou in aws_organizations_organizational_unit.level_3_ous : path => ou.id },
    { for path, ou in aws_organizations_organizational_unit.level_4_ous : path => ou.id },
    { for path, ou in aws_organizations_organizational_unit.level_5_ous : path => ou.id }
  )
}

output "level_1_ous_details" {
  description = "Details of Level 1 Organizational Units with OU path as key."
  value = { for path, ou in aws_organizations_organizational_unit.level_1_ous : path => {
    id        = ou.id
    name      = ou.name
    path      = path
    parent_id = ou.parent_id
    tags      = ou.tags
  } }
}

output "level_2_ous_details" {
  value = { for path, ou in aws_organizations_organizational_unit.level_2_ous : path => {
    id        = ou.id
    name      = ou.name
    path      = path
    parent_id = ou.parent_id
    tags      = ou.tags
  } }
  description = "Details of Level 2 Organizational Units."
}

output "level_3_ous_details" {
  value = { for path, ou in aws_organizations_organizational_unit.level_3_ous : path => {
    id        = ou.id
    name      = ou.name
    path      = path
    parent_id = ou.parent_id
    tags      = ou.tags
  } }
  description = "Details of Level 3 Organizational Units."
}

output "level_4_ous_details" {
  value = { for path, ou in aws_organizations_organizational_unit.level_4_ous : path => {
    id        = ou.id
    name      = ou.name
    path      = path
    parent_id = ou.parent_id
    tags      = ou.tags
  } }
  description = "Details of Level 4 Organizational Units."
}

output "level_5_ous_details" {
  value = { for path, ou in aws_organizations_organizational_unit.level_5_ous : path => {
    id        = ou.id
    name      = ou.name
    path      = path
    parent_id = ou.parent_id
    tags      = ou.tags
  } }
  description = "Details of Level 5 Organizational Units."
}
