# v0.0.2
* removed empty and unrequired file modules/linux_temp/iam.tf
* replaced module/linux_temp with module/launch_template to accommodate windows based templates
* variable launch_template.os added to support windows based templates
    - determines which block_device_mappings values to use (linux or windows)
* cpu_options's two arguments default changed from 1 to null, not supported for default t2.micro instances
* disable_api_stop and disable_api_termination default changed from true to false
    - removes instance stop/termination protection

# v0.0.1
* start of changelog 
