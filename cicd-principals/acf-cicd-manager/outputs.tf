output "cf_template_map" {
  value = {
    "org_mgmt.yaml.tftpl" = replace(data.template_file.org_mgmt.rendered, "$$$", "$$")
  }
}
