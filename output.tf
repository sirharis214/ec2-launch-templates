output "linux_regions_to_create_EC2LT" {
  value = module.linux_temp.regions_to_create_EC2LT
}

output "windows_regions_to_create_EC2LT" {
  value = module.windows_temp.regions_to_create_EC2LT
}
