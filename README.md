# ec2-launch-templates
Creating Linux and Windows based EC2 launch templates

# Usage

As of now, the key difference between creating a Linux based Launch Template and a Windows based is `var.launch_template.os`. The default option is `linux` so if your creating a Launch Template for Linux OS, omit this variable. If you choose to create a Windows based Launch Template, define the variable as `os = "windows"`.

Launch Template relies on the value of this variable when defining the `block_device_mappings` block. If var.launch_template.os = linux, then the values for block_device_mappings will be read from `var.launch_template.linux_block_device_mappings`, otherwise it will read the values from `var.launch_template.windows_block_device_mappings`.

> If you wish to define non-default values for block_device_mappings, you only need to define the desired OS's block_device_mappings variable; ie: for Linux, only define `linux_block_device_mappings`.

## Launch Template | All options
All optional arguments for the variable `linux_temp` default to what is defined below, unless stated otherwise.

```hcl
module "example_launch_template" {
  source = "./modules/launch_template"

  launch_template = {
    name_prefix = "main-linux-temp"
    
    # optional
    os = "linux"  # "linux" or "windows"

    # optional
    # ! only required for linux temp's with non-default block_device_mappings values
    linux_block_device_mappings = {
      device_name = "/dev/xvda",
      ebs = {volume_size = 8}
    }

    # optional
    # ! only required for windows temp's with non-default block_device_mappings values
    windows_block_device_mappings = {
      device_name = "/dev/sda1",
      ebs = {volume_size = 30}
    }

    # optional
    capacity_reservation_specification = {
      capacity_reservation_preference = "none"
    }

    # optional, defaults to null
    cpu_options = {
      core_count = 1
      threads_per_core = 1
    }

    # optional
    credit_specification = {
      cpu_credits = "standard"
    }

    # optional (x3)
    disable_api_stop        = false # If true, enables EC2 Instance Stop Protection.
    disable_api_termination = false # If true, enables EC2 Instance Termination Protection
    ebs_optimized           = false # If true, the launched EC2 instance will be EBS-optimized.

    # optional, defaults to null
    # https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/elastic-graphics.html#elastic-gpus-basics
    elastic_gpu_specifications = {
      type = "eg1.medium"
    }

    # optional, defaults to null
    iam_instance_profile = {
      name = "main-ec2-profile"
    }

    image_id = "ami-00c6177f250e07ec1" # Amazon Linux 2

    # optional
    instance_initiated_shutdown_behavior = "terminate"

    # optional, defaults to null
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html
    instance_market_options = {
      market_type = "spot"
    }

    # optional
    instance_type = "t2.micro"
    
    # optional defaults to null
    kernel_id = "aki-xxxxxxxx"

    key_name = "main-us-east-1"

    # optional, defaults to null
    license_specification = {
      license_configuration_arn = "arn:aws:license-manager:us-east-1:0x0x:license-configuration:lic-0x0x"
    }

    # optional, defaults to null
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1
      instance_metadata_tags      = "enabled"
    }

    # optional, defaults to false
    # if true, the launched EC2 instance will have detailed monitoring enabled
    monitoring = {
      enabled = true
    }

    # optional, defaults to null; Must define if you want instances in VPC
    network_interfaces = {
      # optional, if network_interfaces defined
      associate_public_ip_address = true 
      # optional, if network_interfaces defined
      delete_on_termination = false
      security_groups = [
        "sg-077d89eca08b13f9e", # main-sg
      ]
      subnet_id = "subnet-038c1a5affe144076" # main-public-subnet-1
    }

    # optional, availability_zone defaults to null
    placement = {
      availability_zone = "us-east-1a"
      tenancy = "default"
    }

    # optional, defaults to null
    ram_disk_id = "test"

    # optional, defaults to resource_type = "instance" & tag={}
    tag_specifications = {
      resource_type = "instance"
      tags = {
        Test = "test-tag"
      }
    }

    # optional, defaults to null
    # save user_data.sh script in module and provide path to script
    path_to_user_data_script = "scripts/test_script.sh"
  }

  project_tags = local.tags
}
```

## Linux | Minimum config - in VPC
```hcl
module "example_linux_launch_template" {
  source = "./modules/launch_template"

  launch_template = {
    name_prefix = "main-linux-temp"

    # optional
    # ! only required for linux temp's with non-default block_device_mappings values
    linux_block_device_mappings = {
      device_name = "/dev/xvda",
      ebs = {volume_size = 8}
    }

    # optional, defaults to null
    iam_instance_profile = {
      name = "main-ec2-profile"
    }

    # AMI id
    image_id = "ami-00c6177f250e07ec1" # Amazon Linux 2
    
    # Key pair assigned at launch
    key_name = "main-us-east-1"

    # optional, defaults to null; Must define if you want instances in VPC 
    network_interfaces = {
      security_groups = [
        "sg-077d89eca08b13f9e", # main-sg
      ]
      subnet_id = "subnet-038c1a5affe144076" # main-public-subnet-1
    }

    # optional, defaults to az=null & tenancy="default"
    placement = {
      availability_zone = "us-east-1a"
    }
  }
  project_tags = local.tags
}
``` 

## Windows | Minimum config - in VPC
> **Note**
> variable **launch_template.os** is important here

```hcl
module "example_windows_launch_template" {
  source = "./modules/launch_template"

  launch_template = {
    name_prefix = "main-windows-temp"
    os          = "windows"

    # optional
    # ! only required for windows temp's with non-default block_device_mappings values
    windows_block_device_mappings = {
      device_name = "/dev/sda1",
      ebs = {volume_size = 30}
    }

    # optional, defaults to null
    iam_instance_profile = {
      name = "main-ec2-profile"
    }

    # AMI id
    image_id = "ami-00c6177f250e07ec1" # Amazon Linux 2
    
    # Key pair assigned at launch
    key_name = "main-us-east-1"

    # optional, defaults to null; Must define if you want instances in VPC 
    network_interfaces = {
      security_groups = [
        "sg-077d89eca08b13f9e", # main-sg
      ]
      subnet_id = "subnet-038c1a5affe144076" # main-public-subnet-1
    }

    # optional, defaults to az=null & tenancy="default"
    placement = {
      availability_zone = "us-east-1a"
    }
  }
  project_tags = local.tags
}
``` 
