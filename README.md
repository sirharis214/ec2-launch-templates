# ec2-launch-templates
Creating Linux and Windows based EC2 launch templates

# Usage

## Linux Launch Template

### Linux | Minimum config - in VPC
```hcl
module "example_linux_launch_template" {
  source = "./modules/linux_temp"

  linux_temp = {
    name_prefix = "main-linux-temp"

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

### Linux | All options
All optional arguments for the variable `linux_temp` default to what is defined below, unless stated otherwise.

```hcl
module "example_linux_launch_template" {
  source = "./modules/linux_temp"

  linux_temp = {
    name_prefix = "main-linux-temp"

    # optional
    block_device_mappings = {
      device_name = "/dev/xvda",
      ebs = {volume_size = 8}
    }

    # optional
    capacity_reservation_specification = {
      capacity_reservation_preference = "none"
    }

    # optional
    cpu_options = {
      core_count = 1
      threads_per_core = 1
    }

    # optional
    credit_specification = {
      cpu_credits = "standard"
    }

    # optional (x3)
    disable_api_stop        = true
    disable_api_termination = true
    ebs_optimized           = false

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
