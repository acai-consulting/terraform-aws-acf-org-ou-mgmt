data "template_file" "org_mgmt" {
  template = file("${path.module}/org_mgmt.yaml.tftpl")
  vars = {
  }
}
