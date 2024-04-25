output "root_ou" {
  value = local.level_0_ous_path
}

output "level_1_ous_paths" {
  value = local.level_1_ous_paths
}

output "level_2_ous_paths" {
  value = local.level_2_ous_paths
}

output "level_3_ous_paths" {
  value = local.level_3_ous_paths
}

output "level_4_ous_paths" {
  value = local.level_4_ous_paths
}

output "level_5_ous_paths" {
  value = local.level_5_ous_paths
}


output "ous_paths" {
  value = merge(
    local.level_0_ous_path,
    local.level_1_ous_paths,
    local.level_2_ous_paths,
    local.level_3_ous_paths,
    local.level_4_ous_paths,
    local.level_5_ous_paths
  )
}