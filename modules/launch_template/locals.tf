locals {
  regions_to_create_EC2LT = keys(var.launch_template.regions)
}
