# ---------------
/** US-EAST-1 **/
# ---------------

resource "aws_launch_template" "us_east_1" {
  for_each = { for region_name, region_data in var.launch_template.regions : region_name => region_data if region_name == "us-east-1" }

  name_prefix = "${var.launch_template.name_prefix}-"

  # support Linux or Windows based values
  block_device_mappings {    
    device_name = lower(var.launch_template.os) == "linux" ? var.launch_template.linux_block_device_mappings.device_name : var.launch_template.windows_block_device_mappings.device_name
    ebs {
      volume_size = lower(var.launch_template.os) == "linux" ? var.launch_template.linux_block_device_mappings.ebs.volume_size : var.launch_template.windows_block_device_mappings.ebs.volume_size
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = var.launch_template.capacity_reservation_specification.capacity_reservation_preference
  }

  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/cpu-options-supported-instances-values.html
  dynamic "cpu_options" {
    for_each = var.launch_template.cpu_options != null ? [1] : []
    content {
      core_count = var.launch_template.cpu_options.core_count
      threads_per_core = var.launch_template.cpu_options.threads_per_core
    }
  }

  credit_specification {
    cpu_credits = var.launch_template.credit_specification.cpu_credits
  }

  disable_api_stop        = var.launch_template.disable_api_stop
  disable_api_termination = var.launch_template.disable_api_termination
  ebs_optimized           = var.launch_template.ebs_optimized

  # Amazon Elastic Graphics will reach end of life on January 8, 2024. 
  # Starting September 5, 2023 the service is no longer accepting new customer accounts
  # for list of supported instance type this is available for:
  # https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/elastic-graphics.html#elastic-gpus-basics
  dynamic "elastic_gpu_specifications" {
    for_each = var.launch_template.elastic_gpu_specifications != null ? [1] : []
    content {
      type = var.launch_template.elastic_gpu_specifications.type
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.launch_template.iam_instance_profile.name != null ? [1] : []
    content {
      name = var.launch_template.iam_instance_profile.name
    }
  }

  image_id = each.value.image_id
  instance_initiated_shutdown_behavior = var.launch_template.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.launch_template.instance_market_options != null ? [1] : []
    content {
      market_type = var.launch_template.instance_market_options.market_type
    }
  }

  instance_type = var.launch_template.instance_type
  kernel_id     = var.launch_template.kernel_id
  key_name      = each.value.key_name

  dynamic "license_specification" {
    for_each = var.launch_template.license_specification != null ? [1] : []
    content {
      license_configuration_arn = var.launch_template.license_specification.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = var.launch_template.metadata_options != null ? [1] : []
    content {
      http_endpoint               = var.launch_template.metadata_options.http_endpoint
      http_tokens                 = var.launch_template.metadata_options.http_tokens
      http_put_response_hop_limit = var.launch_template.metadata_options.http_put_response_hop_limit
      instance_metadata_tags      = var.launch_template.metadata_options.instance_metadata_tags
    }
  }

  monitoring {
    enabled = var.launch_template.monitoring.enabled
  }

  dynamic "network_interfaces" {
    for_each = each.value.network_interfaces != null ? [1] : [0]
    content {
      associate_public_ip_address = each.value.network_interfaces.associate_public_ip_address
      delete_on_termination = each.value.network_interfaces.delete_on_termination
      security_groups = each.value.network_interfaces.security_groups
      subnet_id = each.value.network_interfaces.subnet_id
    }
  }

  placement {
    availability_zone = each.value.placement.availability_zone
    tenancy           = each.value.placement.tenancy
  }

  ram_disk_id = var.launch_template.ram_disk_id

  dynamic "tag_specifications" {
    for_each = merge(each.value.regional_tags, var.launch_template.tag_specifications.tags) != {} ? [1] : []
    content {
      resource_type = var.launch_template.tag_specifications.resource_type
      tags = merge(each.value.regional_tags, var.launch_template.tag_specifications.tags)
    }
  }

  user_data = var.launch_template.path_to_user_data_script == null ? null : filebase64("${path.module}/${var.launch_template.path_to_user_data_script}")

  tags = local.tags  
}

# ---------------
/** US-EAST-2 **/
# ---------------

resource "aws_launch_template" "us_east_2" {
  for_each = { for region_name, region_data in var.launch_template.regions : region_name => region_data if region_name == "us-east-2" }
  
  provider = aws.us-east-2
  name_prefix = "${var.launch_template.name_prefix}-"

  # support Linux or Windows based values
  block_device_mappings {    
    device_name = lower(var.launch_template.os) == "linux" ? var.launch_template.linux_block_device_mappings.device_name : var.launch_template.windows_block_device_mappings.device_name
    ebs {
      volume_size = lower(var.launch_template.os) == "linux" ? var.launch_template.linux_block_device_mappings.ebs.volume_size : var.launch_template.windows_block_device_mappings.ebs.volume_size
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = var.launch_template.capacity_reservation_specification.capacity_reservation_preference
  }

  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/cpu-options-supported-instances-values.html
  dynamic "cpu_options" {
    for_each = var.launch_template.cpu_options != null ? [1] : []
    content {
      core_count = var.launch_template.cpu_options.core_count
      threads_per_core = var.launch_template.cpu_options.threads_per_core
    }
  }

  credit_specification {
    cpu_credits = var.launch_template.credit_specification.cpu_credits
  }

  disable_api_stop        = var.launch_template.disable_api_stop
  disable_api_termination = var.launch_template.disable_api_termination
  ebs_optimized           = var.launch_template.ebs_optimized

  # Amazon Elastic Graphics will reach end of life on January 8, 2024. 
  # Starting September 5, 2023 the service is no longer accepting new customer accounts
  # for list of supported instance type this is available for:
  # https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/elastic-graphics.html#elastic-gpus-basics
  dynamic "elastic_gpu_specifications" {
    for_each = var.launch_template.elastic_gpu_specifications != null ? [1] : []
    content {
      type = var.launch_template.elastic_gpu_specifications.type
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.launch_template.iam_instance_profile.name != null ? [1] : []
    content {
      name = var.launch_template.iam_instance_profile.name
    }
  }

  image_id = each.value.image_id
  instance_initiated_shutdown_behavior = var.launch_template.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.launch_template.instance_market_options != null ? [1] : []
    content {
      market_type = var.launch_template.instance_market_options.market_type
    }
  }

  instance_type = var.launch_template.instance_type
  kernel_id     = var.launch_template.kernel_id
  key_name      = each.value.key_name

  dynamic "license_specification" {
    for_each = var.launch_template.license_specification != null ? [1] : []
    content {
      license_configuration_arn = var.launch_template.license_specification.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = var.launch_template.metadata_options != null ? [1] : []
    content {
      http_endpoint               = var.launch_template.metadata_options.http_endpoint
      http_tokens                 = var.launch_template.metadata_options.http_tokens
      http_put_response_hop_limit = var.launch_template.metadata_options.http_put_response_hop_limit
      instance_metadata_tags      = var.launch_template.metadata_options.instance_metadata_tags
    }
  }

  monitoring {
    enabled = var.launch_template.monitoring.enabled
  }

  dynamic "network_interfaces" {
    for_each = each.value.network_interfaces != null ? [1] : [0]
    content {
      associate_public_ip_address = each.value.network_interfaces.associate_public_ip_address
      delete_on_termination = each.value.network_interfaces.delete_on_termination
      security_groups = each.value.network_interfaces.security_groups
      subnet_id = each.value.network_interfaces.subnet_id
    }
  }

  placement {
    availability_zone = each.value.placement.availability_zone
    tenancy           = each.value.placement.tenancy
  }

  ram_disk_id = var.launch_template.ram_disk_id

  dynamic "tag_specifications" {
    for_each = merge(each.value.regional_tags, var.launch_template.tag_specifications.tags) != {} ? [1] : []
    content {
      resource_type = var.launch_template.tag_specifications.resource_type
      tags = merge(each.value.regional_tags, var.launch_template.tag_specifications.tags)
    }
  }

  user_data = var.launch_template.path_to_user_data_script == null ? null : filebase64("${path.module}/${var.launch_template.path_to_user_data_script}")

  tags = local.tags  
}

# ---------------
/** US-WEST-1 **/
# ---------------

resource "aws_launch_template" "us_west_1" {
  for_each = { for region_name, region_data in var.launch_template.regions : region_name => region_data if region_name == "us-west-1" }

  name_prefix = "${var.launch_template.name_prefix}-"

  # support Linux or Windows based values
  block_device_mappings {    
    device_name = lower(var.launch_template.os) == "linux" ? var.launch_template.linux_block_device_mappings.device_name : var.launch_template.windows_block_device_mappings.device_name
    ebs {
      volume_size = lower(var.launch_template.os) == "linux" ? var.launch_template.linux_block_device_mappings.ebs.volume_size : var.launch_template.windows_block_device_mappings.ebs.volume_size
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = var.launch_template.capacity_reservation_specification.capacity_reservation_preference
  }

  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/cpu-options-supported-instances-values.html
  dynamic "cpu_options" {
    for_each = var.launch_template.cpu_options != null ? [1] : []
    content {
      core_count = var.launch_template.cpu_options.core_count
      threads_per_core = var.launch_template.cpu_options.threads_per_core
    }
  }

  credit_specification {
    cpu_credits = var.launch_template.credit_specification.cpu_credits
  }

  disable_api_stop        = var.launch_template.disable_api_stop
  disable_api_termination = var.launch_template.disable_api_termination
  ebs_optimized           = var.launch_template.ebs_optimized

  # Amazon Elastic Graphics will reach end of life on January 8, 2024. 
  # Starting September 5, 2023 the service is no longer accepting new customer accounts
  # for list of supported instance type this is available for:
  # https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/elastic-graphics.html#elastic-gpus-basics
  dynamic "elastic_gpu_specifications" {
    for_each = var.launch_template.elastic_gpu_specifications != null ? [1] : []
    content {
      type = var.launch_template.elastic_gpu_specifications.type
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.launch_template.iam_instance_profile.name != null ? [1] : []
    content {
      name = var.launch_template.iam_instance_profile.name
    }
  }

  image_id = each.value.image_id
  instance_initiated_shutdown_behavior = var.launch_template.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.launch_template.instance_market_options != null ? [1] : []
    content {
      market_type = var.launch_template.instance_market_options.market_type
    }
  }

  instance_type = var.launch_template.instance_type
  kernel_id     = var.launch_template.kernel_id
  key_name      = each.value.key_name

  dynamic "license_specification" {
    for_each = var.launch_template.license_specification != null ? [1] : []
    content {
      license_configuration_arn = var.launch_template.license_specification.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = var.launch_template.metadata_options != null ? [1] : []
    content {
      http_endpoint               = var.launch_template.metadata_options.http_endpoint
      http_tokens                 = var.launch_template.metadata_options.http_tokens
      http_put_response_hop_limit = var.launch_template.metadata_options.http_put_response_hop_limit
      instance_metadata_tags      = var.launch_template.metadata_options.instance_metadata_tags
    }
  }

  monitoring {
    enabled = var.launch_template.monitoring.enabled
  }

  dynamic "network_interfaces" {
    for_each = each.value.network_interfaces != null ? [1] : [0]
    content {
      associate_public_ip_address = each.value.network_interfaces.associate_public_ip_address
      delete_on_termination = each.value.network_interfaces.delete_on_termination
      security_groups = each.value.network_interfaces.security_groups
      subnet_id = each.value.network_interfaces.subnet_id
    }
  }

  placement {
    availability_zone = each.value.placement.availability_zone
    tenancy           = each.value.placement.tenancy
  }

  ram_disk_id = var.launch_template.ram_disk_id

  dynamic "tag_specifications" {
    for_each = merge(each.value.regional_tags, var.launch_template.tag_specifications.tags) != {} ? [1] : []
    content {
      resource_type = var.launch_template.tag_specifications.resource_type
      tags = merge(each.value.regional_tags, var.launch_template.tag_specifications.tags)
    }
  }

  user_data = var.launch_template.path_to_user_data_script == null ? null : filebase64("${path.module}/${var.launch_template.path_to_user_data_script}")

  tags = local.tags  
}

# ---------------
/** US-WEST-2 **/
# ---------------

resource "aws_launch_template" "us_west_2" {
  for_each = { for region_name, region_data in var.launch_template.regions : region_name => region_data if region_name == "us-west-2" }

  name_prefix = "${var.launch_template.name_prefix}-"

  # support Linux or Windows based values
  block_device_mappings {    
    device_name = lower(var.launch_template.os) == "linux" ? var.launch_template.linux_block_device_mappings.device_name : var.launch_template.windows_block_device_mappings.device_name
    ebs {
      volume_size = lower(var.launch_template.os) == "linux" ? var.launch_template.linux_block_device_mappings.ebs.volume_size : var.launch_template.windows_block_device_mappings.ebs.volume_size
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = var.launch_template.capacity_reservation_specification.capacity_reservation_preference
  }

  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/cpu-options-supported-instances-values.html
  dynamic "cpu_options" {
    for_each = var.launch_template.cpu_options != null ? [1] : []
    content {
      core_count = var.launch_template.cpu_options.core_count
      threads_per_core = var.launch_template.cpu_options.threads_per_core
    }
  }

  credit_specification {
    cpu_credits = var.launch_template.credit_specification.cpu_credits
  }

  disable_api_stop        = var.launch_template.disable_api_stop
  disable_api_termination = var.launch_template.disable_api_termination
  ebs_optimized           = var.launch_template.ebs_optimized

  # Amazon Elastic Graphics will reach end of life on January 8, 2024. 
  # Starting September 5, 2023 the service is no longer accepting new customer accounts
  # for list of supported instance type this is available for:
  # https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/elastic-graphics.html#elastic-gpus-basics
  dynamic "elastic_gpu_specifications" {
    for_each = var.launch_template.elastic_gpu_specifications != null ? [1] : []
    content {
      type = var.launch_template.elastic_gpu_specifications.type
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.launch_template.iam_instance_profile.name != null ? [1] : []
    content {
      name = var.launch_template.iam_instance_profile.name
    }
  }

  image_id = each.value.image_id
  instance_initiated_shutdown_behavior = var.launch_template.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.launch_template.instance_market_options != null ? [1] : []
    content {
      market_type = var.launch_template.instance_market_options.market_type
    }
  }

  instance_type = var.launch_template.instance_type
  kernel_id     = var.launch_template.kernel_id
  key_name      = each.value.key_name

  dynamic "license_specification" {
    for_each = var.launch_template.license_specification != null ? [1] : []
    content {
      license_configuration_arn = var.launch_template.license_specification.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = var.launch_template.metadata_options != null ? [1] : []
    content {
      http_endpoint               = var.launch_template.metadata_options.http_endpoint
      http_tokens                 = var.launch_template.metadata_options.http_tokens
      http_put_response_hop_limit = var.launch_template.metadata_options.http_put_response_hop_limit
      instance_metadata_tags      = var.launch_template.metadata_options.instance_metadata_tags
    }
  }

  monitoring {
    enabled = var.launch_template.monitoring.enabled
  }

  dynamic "network_interfaces" {
    for_each = each.value.network_interfaces != null ? [1] : [0]
    content {
      associate_public_ip_address = each.value.network_interfaces.associate_public_ip_address
      delete_on_termination = each.value.network_interfaces.delete_on_termination
      security_groups = each.value.network_interfaces.security_groups
      subnet_id = each.value.network_interfaces.subnet_id
    }
  }

  placement {
    availability_zone = each.value.placement.availability_zone
    tenancy           = each.value.placement.tenancy
  }

  ram_disk_id = var.launch_template.ram_disk_id

  dynamic "tag_specifications" {
    for_each = merge(each.value.regional_tags, var.launch_template.tag_specifications.tags) != {} ? [1] : []
    content {
      resource_type = var.launch_template.tag_specifications.resource_type
      tags = merge(each.value.regional_tags, var.launch_template.tag_specifications.tags)
    }
  }

  user_data = var.launch_template.path_to_user_data_script == null ? null : filebase64("${path.module}/${var.launch_template.path_to_user_data_script}")

  tags = local.tags  
}
