# Multi Region EC2 Launch Template

In order to support a multi-region deployment of the EC2 launch template we had to perform some terraform wizardry as-well as add copies of the aws_launch_template resource block per-region, (no a for_each would not have worked here). Before we get to that, we need to understand the current module `v0.0.2` and how it could not support a multi region deployment without the copies of the resource block.

## v0.0.2

In v0.0.2 we had a single aws_launch_template resource block. The first step to support multi-region deployment was to identify which variables would be region specific and which would be global across all regions. Some obvious candidites for this are AMI-id, Subnet-id, Security Groups and Key-Name as these are all unique across regions. 

The plan was to create a sub-variable under `launch_template` called `regions` which would be map(object) that includes the values for these variables per region. In the module we do a for_each loop over the `regions` variable so that the resource block is created as many times as the number of regions we defined unique variables for.

### example

With the module and instance of module defined below, we would get 2 itterations of the resource block in the module. 

Thats becuase in the (Instance of Module example)[#instance-of-module-example]'s variable launch_template.regions, we have 2 key => values defining region specific variables, us-east-1 and us-east-2.

In the module, the variable local.all_regions loops over this var.launch_template.regions map and creates a list of objects where the objects are the region specific variables, then in the resource we do a for_each over local.all_regions which determines how many itterations of the resource will be created.

#### module example
```hcl
locals {
  # list(object) for region specific variables
  all_regions = [
    for region_name, region_data in var.launch_template.regions : {
      region                    = region_name
      region_image_id           = region_data.image_id
      region_key_name           = region_data.key_name
      region_network_interfaces = region_data.network_interfaces
      region_placement          = region_data.placement
      region_regional_tags      = merge(region_data.regional_tags, var.launch_template.tag_specifications.tags)
    }
  ]
}

resource "aws_launch_template" "this" {
  for_each = {
    for index, region_data in local.all_regions: region_data.region => region_data
  }

  name_prefix = "${var.launch_template.name_prefix}-"

  ...

  image_id = each.value.region_image_id
  instance_initiated_shutdown_behavior = var.launch_template.instance_initiated_shutdown_behavior

  ...

  instance_type = var.launch_template.instance_type
  kernel_id     = var.launch_template.kernel_id
  key_name      = each.value.region_key_name

  ...

  dynamic "network_interfaces" {
    for_each = each.value.region_network_interfaces != null ? [1] : [0]
    content {
      associate_public_ip_address = each.value.region_network_interfaces.associate_public_ip_address
      delete_on_termination = each.value.region_network_interfaces.delete_on_termination
      security_groups = each.value.region_network_interfaces.security_groups
      subnet_id = each.value.region_network_interfaces.subnet_id
    }
  }

  placement {
    availability_zone = each.value.region_placement.availability_zone
    tenancy           = each.value.region_placement.tenancy
  }

  ram_disk_id = var.launch_template.ram_disk_id

  dynamic "tag_specifications" {
    for_each = each.value.region_regional_tags != {} ? [1] : []
    content {
      resource_type = var.launch_template.tag_specifications.resource_type
      tags = each.value.region_regional_tags
    }
  }

  tags = local.tags  
}
```

#### Instance of Module example
```hcl
module "test_linux_temp" {
  source = "./modules/launch_template"

  launch_template = {
    name_prefix = "test-linux-temp"

    iam_instance_profile = {
      name = "main-ec2-profile"
    }

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
      us-east-2 = {
        image_id = "ami-0aec300fa613b1c92" # us-east-2 Amazon Linux 2
        network_interfaces = {
          security_groups = [
            "sg-041b3e39b881e6063" # default
          ]
          subnet_id = "subnet-06c63da68c902e819" # default public ; us-east-2a 
        }
        regional_tags = {
          Block_Region = "us-east-2"
        }
      }
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

#### local.all_regions
This is what the local variable looks like after it does the loop over var.launch_template.regions.

```hcl
[
  {
    region                    = "us-east-1"
    region_image_id           = "ami-0bb4c991fa89d4b9b"
    region_key_name           = "main-us-east-1"
    region_network_interfaces = {
      associate_public_ip_address = null
      delete_on_termination = null
      security_groups = [
        "sg-077d89eca08b13f9e",
      ]
      subnet_id = "subnet-038c1a5affe144076"
    }
    region_placement = {
        availability_zone = null
        tenancy           = "default"
    }
    region_regional_tags      = {
      Block_Region = "us-east-1"
    }
  },
  {
    region                    = "us-east-2"
    region_image_id           = "ami-0aec300fa613b1c92"
    region_key_name           = null
    region_network_interfaces = {
      associate_public_ip_address = null
      delete_on_termination       = null
      security_groups             = [
        "sg-041b3e39b881e6063",
      ]
      subnet_id                   = "subnet-06c63da68c902e819"
    }
    region_placement          = {
        availability_zone = null
        tenancy           = "default"
    }
    region_regional_tags      = {
      Block_Region = "us-east-2"
    }
  }
]
```

#### Resource's for_each
This is what the for_each looks like after it does the loop over local.all_regions.

```hcl
{
  us-east-1 = {
    region                    = "us-east-1"
    region_image_id           = "ami-0aec300fa613b1c92"
    region_key_name           = "main-us-east-1"
    region_network_interfaces = {
      associate_public_ip_address = null
      delete_on_termination       = null
      security_groups             = [
        "sg-041b3e39b881e6063",
      ]
      subnet_id                   = "subnet-06c63da68c902e819"
    }
    region_placement          = {
      availability_zone = null
      tenancy           = "default"
    }
    region_regional_tags      = {
      Block_Region = "us-east-1"
    }
  },
  us-east-2 = {
    region                    = "us-east-2"
    region_image_id           = "ami-0aec300fa613b1c92"
    region_key_name           = null
    region_network_interfaces = {
      associate_public_ip_address = null
      delete_on_termination       = null
      security_groups             = [
        "sg-041b3e39b881e6063",
      ]
      subnet_id                   = "subnet-06c63da68c902e819"
    }
    region_placement          = {
      availability_zone = null
      tenancy           = "default"
    }
    region_regional_tags      = {
      Block_Region = "us-east-2"
      OS           = "linux"
    }
  }
}
```











# Usage
```hcl
module "test_linux_temp" {
  source = "./modules/launch_template"

  launch_template = {
    name_prefix = "test-linux-temp"

    iam_instance_profile = {
      name = "main-ec2-profile"
    }

    tag_specifications = {
      tags = {
        OS = "linux"
      }
    }

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
      us-east-2 = {
        image_id = "ami-0aec300fa613b1c92" # us-east-2 Amazon Linux 2
        network_interfaces = {
          security_groups = [
            "sg-041b3e39b881e6063" # default
          ]
          subnet_id = "subnet-06c63da68c902e819" # default public ; us-east-2a 
        }
        regional_tags = {
          Block_Region = "us-east-2"
        }
      }
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