# ec2-launch-templates
Creating Linux and Windows based EC2 launch templates

# Usage

As of now, the key difference between creating a **Linux** based or **Windows** based Launch Template is the value of `var.launch_template.os`. 

* For Linux based Launch Templates: omit this variable because the default value is `linux`
* For Windows based Launch Templates: you must define the variable var.launch_template.os and assign the value `windows`

```hcl
module "example_windows_temp" {
  source = "./modules/launch_template"

  launch_template = {
    name_prefix = "example-windows-temp"
    os          = "windows"
  }
}
```

Continue reading to see which variables are required regardless of the OS and which are OS dependent. See [Linux minimum config - in VPC](#linux--minimum-config---in-vpc) for an example creating Linux based Launch Template.

## OS Dependent Variable

Variables that are OS dependant:

1. var.launch_template.**block_device_mappings**

The module's aws_launch_template resource relies on the value of `var.launch_template.os` when setting configurations for `block_device_mappings`. 

Theres logic in place to set the values of block_device_mappings depending on which OS the launch template is for.

* If var.launch_template.os = linux, the values are read from `var.launch_template.linux_block_device_mappings`
* If var.launch_template.os = windows, the values are read from `var.launch_template.windows_block_device_mappings`.

> **linux_block_device_mappings** and **windows_block_device_mappings** are optional variables that have default values. If you choose to stick with the default values, it is suffient to only define the var.launch_template.os variable and omit the said variables.

## Launch Template | All options
All optional arguments for the variable `launch_template` default to what is defined below, unless stated otherwise.

```hcl
module "example_linux_launch_template" {
  source = "./modules/launch_template"

  launch_template = {
    name_prefix = "example-linux-temp"
    
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

    # optional, defaults to null
    ram_disk_id = "test"

    # optional, defaults to resource_type = "instance" & tag = {}
    tag_specifications = {
      resource_type = "instance"
      tags = {
        Test = "test-tag"
      }
    }

    # optional, defaults to null
    # save user_data.sh script in module and provide path to script
    path_to_user_data_script = "scripts/test_script.sh"

    # REQUIRED
    regions = {
      us-east-1 = {
        image_id = "ami-0bb4c991fa89d4b9b" # us-east-1 Amazon Linux 2
        
        # optional, defaults to null
        key_name = "main-us-east-1"

        # optional, defaults to null; Should define if we need EC2 instance placed in VPC
        network_interfaces = {
          # optional, defaults to null
          associate_public_ip_address = true

          # optional, defaults to null
          delete_on_termination = true

          security_groups = [
            "sg-077d89eca08b13f9e" # main-sg
          ]
          subnet_id = "subnet-038c1a5affe144076" # main-public-subnet-1 ; us-east-1a
        }

        # optional, defaults to availability_zone = null, tenancy = "default"
        placement = {
          availability_zone = "us-east-1a"
          tenancy = "default"
        }

        # optional, defaults to empty map {}
        regional_tags = {
          Block_Region = "us-east-1"
        }
      },
    }
  }

  project_tags = local.tags

  providers = {
    aws           = aws
    aws.us-east-2 = aws.us-east-2
    aws.us-west-1 = aws.us-west-1
    aws.us-west-2 = aws.us-west-2
  }
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

    # single region launch template
    regions = {
      us-east-1 = {
        image_id = "ami-0bb4c991fa89d4b9b" # us-east-1 Amazon Linux 2
        key_name = "main-us-east-1"
        network_interfaces = {
          security_groups = [
            "sg-077d89eca08b13f9e" # main-sg
          ]
          subnet_id = "subnet-038c1a5affe144076" # main-public-subnet-1 ; us-east-1a
        }
        regional_tags = {
          Block_Region = "us-east-1"
        }
      },
    }
  }
  project_tags = local.tags
  providers = {
    aws           = aws
    aws.us-east-2 = aws.us-east-2
    aws.us-west-1 = aws.us-west-1
    aws.us-west-2 = aws.us-west-2
  }
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

    # optional, defaults tags = {}
    tag_specifications = {
      tags = {
        OS = "windows"
      }
    }

    # single region launch template
    regions = {
      us-east-1 = {
        image_id =  "ami-0be0e902919675894" # us-east-1 Microsoft Windows Server 2022 Base
        key_name = "main-us-east-1"
        network_interfaces = {
          security_groups = [
            "sg-077d89eca08b13f9e" # main-sg
          ]
          subnet_id = "subnet-038c1a5affe144076" # main-public-subnet-1 ; us-east-1a
        }
        regional_tags = {
          Block_Region = "us-east-1"
        }
      },
    }
  }
  project_tags = local.tags
  providers = {
    aws           = aws
    aws.us-east-2 = aws.us-east-2
    aws.us-west-1 = aws.us-west-1
    aws.us-west-2 = aws.us-west-2
  }
}
``` 
