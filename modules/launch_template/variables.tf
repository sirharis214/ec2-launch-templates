variable "project_tags" {
  type        = map(string)
  description = "Incoming project tags to be merged with local module tags"
}

variable "launch_template" {
  type = object({
    name_prefix = string
    os          = optional(string, "linux")

    linux_block_device_mappings = optional(
      object({
        device_name = string,
        ebs = object({volume_size = number})
      }),
      {
        device_name = "/dev/xvda",
        ebs = {volume_size = 8}
      }
    ),

    windows_block_device_mappings = optional(
      object({
        device_name = string,
        ebs = object({volume_size = number})
      }),
      {
        device_name = "/dev/sda1",
        ebs = {volume_size = 30}
      }
    ),

    capacity_reservation_specification = optional(
      object({
        capacity_reservation_preference = string
      }),
      {
        capacity_reservation_preference = "none"
      }
    ),

    cpu_options = optional(
      object({
        core_count = number
        threads_per_core = number
      }),
      null
    ),

    credit_specification = optional(
      object({
        cpu_credits = string
      }),
      {
        cpu_credits = "standard"
      }
    ),

    disable_api_stop        = optional(bool, false) # If true, enables EC2 Instance Stop Protection.
    disable_api_termination = optional(bool, false) # If true, enables EC2 Instance Termination Protection
    ebs_optimized           = optional(bool, false) # If true, the launched EC2 instance will be EBS-optimized

    elastic_gpu_specifications = optional(
      object({
        type = string
      }),
      {
        type = null
      }
    ),

    iam_instance_profile = optional(
      object({
        name = string
      }),
      {
        name = null
      }
    ),

    instance_initiated_shutdown_behavior = optional(string, "terminate")

    instance_market_options = optional(
      object({
        market_type = string
      }),
      {
        market_type = null
      }
    ),

    instance_type = optional(string, "t2.micro")
    kernel_id     = optional(string, null)

    license_specification = optional(
      object({
        license_configuration_arn = string
      }),
      {
        license_configuration_arn = null
      }
    ),

    metadata_options = optional(
      object({
        http_endpoint               = optional(string, null)
        http_tokens                 = optional(string, null)
        http_put_response_hop_limit = optional(number, null)
        instance_metadata_tags      = optional(string, null)
      }),
      null
    ),

    monitoring = optional(
      object({
        enabled = bool
      }),
      {
        enabled = false
      }
    ),

    ram_disk_id = optional(string, null)

    tag_specifications = optional(
      object({
        resource_type = optional(string, "instance")
        tags = map(any)
      }),
      {
        resource_type = "instance"
        tags = {}
      }
    ),

    path_to_user_data_script = optional(string, null)

    regions = map(
      object({
        image_id = string,
        key_name = optional(string, null),
        network_interfaces = optional(
          object({
            associate_public_ip_address = optional(bool, null)
            delete_on_termination = optional(bool, null)
            security_groups = list(string)
            subnet_id = string
          }),
          null
        ),
        placement = optional(
          object({
            availability_zone = string
            tenancy = optional(string)
          }),
          {
            availability_zone = null
            tenancy = "default"
          }
        ),
        regional_tags = optional(map(any), {})
      }) # close regions object
    ), # close regions map
  })
}
