output "example_complete" {
  description = "example_complete"
  value       = module.example_complete
}

output "test_success1" {
  description = "Check if specific OU-Path exists."
  value       = module.example_complete.level_3_ous_details["/root/level1_unit1/level1_unit1__level2_unit2/level1_unit1__level2_unit2__level3_unit1"].name == "level1_unit1__level2_unit2__level3_unit1"
}

output "test_success2" {
  description = "Check if specific OU-Path exists."
  value       = lookup(module.example_complete.organizational_units_paths_ids, "/root/WorkloadAccounts/BusinessUnit_1/Prod", null) != null
}

output "example_reporting" {
  description = "example_reporting"
  value       = module.example_reporting
}

output "test_success3" {
  description = "Check if specific OU-Path exists."
  value       = contains(keys(module.example_reporting.ous_paths), "/root/WorkloadAccounts/BusinessUnit_1/Prod")
}
