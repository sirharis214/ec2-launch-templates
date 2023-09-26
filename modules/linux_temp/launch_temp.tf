resource "aws_launch_template" "linux_template" {

  name_prefix = "${var.linux_temp.name_prefix}-"

  block_device_mappings {
    device_name = var.linux_temp.block_device_mappings.device_name

    ebs {
      volume_size = var.linux_temp.block_device_mappings.ebs.volume_size
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = var.linux_temp.capacity_reservation_specification.capacity_reservation_preference
  }

  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/cpu-options-supported-instances-values.html
  cpu_options {
    core_count       = var.linux_temp.cpu_options.core_count
    threads_per_core = var.linux_temp.cpu_options.threads_per_core
  }

  credit_specification {
    cpu_credits = var.linux_temp.credit_specification.cpu_credits
  }

  disable_api_stop        = var.linux_temp.disable_api_stop
  disable_api_termination = var.linux_temp.disable_api_termination
  ebs_optimized           = var.linux_temp.ebs_optimized

  # Amazon Elastic Graphics will reach end of life on January 8, 2024. 
  # Starting September 5, 2023 the service is no longer accepting new customer accounts
  # for list of supported instance type this is available for:
  # https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/elastic-graphics.html#elastic-gpus-basics
  dynamic "elastic_gpu_specifications" {
    for_each = var.linux_temp.elastic_gpu_specifications.type != null ? [1] : []
    content {
      type = var.linux_temp.elastic_gpu_specifications.type
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.linux_temp.iam_instance_profile.name != null ? [1] : []
    content {
      name = var.linux_temp.iam_instance_profile.name
    }
  }

  image_id = var.linux_temp.image_id
  instance_initiated_shutdown_behavior = var.linux_temp.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.linux_temp.instance_market_options.market_type != null ? [1] : []
    content {
      market_type = var.linux_temp.instance_market_options.market_type
    }
  }

  instance_type = var.linux_temp.instance_type
  kernel_id     = var.linux_temp.kernel_id
  key_name      = var.linux_temp.key_name

  dynamic "license_specification" {
    for_each = var.linux_temp.license_specification.license_configuration_arn != null ? [1] : []
    content {
      license_configuration_arn = var.linux_temp.license_specification.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = var.linux_temp.metadata_options != null ? [1] : []
    content {
      http_endpoint               = var.linux_temp.metadata_options.http_endpoint
      http_tokens                 = var.linux_temp.metadata_options.http_tokens
      http_put_response_hop_limit = var.linux_temp.metadata_options.http_put_response_hop_limit
      instance_metadata_tags      = var.linux_temp.metadata_options.instance_metadata_tags
    }
  }

  monitoring {
    enabled = var.linux_temp.monitoring.enabled
  }

  dynamic "network_interfaces" {
    for_each = var.linux_temp.network_interfaces != null ? [1] : []
    content {
      associate_public_ip_address = var.linux_temp.network_interfaces.associate_public_ip_address
      delete_on_termination = var.linux_temp.network_interfaces.delete_on_termination
      security_groups = var.linux_temp.network_interfaces.security_groups
      subnet_id = var.linux_temp.network_interfaces.subnet_id
    }
  }

  dynamic "placement" {
    for_each = var.linux_temp.placement != null ? [1] : []
    content {
      availability_zone = var.linux_temp.placement.availability_zone
      tenancy = var.linux_temp.placement.tenancy
    }
  }

  ram_disk_id = var.linux_temp.ram_disk_id

  dynamic "tag_specifications" {
    for_each = var.linux_temp.tag_specifications.tags != {} ? [1] : []
    content {
      resource_type = var.linux_temp.tag_specifications.resource_type
      tags = var.linux_temp.tag_specifications.tags
    }
  }

  user_data = var.linux_temp.path_to_user_data_script == null ? null : filebase64("${path.module}/${var.linux_temp.path_to_user_data_script}")

  tags = local.tags
}