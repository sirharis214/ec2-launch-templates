# Multi Region EC2 Launch Template

In order to support a multi-region deployment of the EC2 launch template we had to add copies of the aws_launch_template resource block per-region, (no a for_each would not have worked here). Before we get to why a for_each on the resource block would not have worked, we need to understand the current module `v0.0.2`.

## v0.0.2

In v0.0.2 we had a single aws_launch_template resource block. The first step to support multi-region deployment was to identify which variables would be region specific and which would be global across all regions. Some obvious candidites for this are AMI-id, Subnet-id, Security Groups and Key-Name as these are all unique across regions. 

The plan was to create a sub-variable under `launch_template` called `regions` which would be map(object) that includes the values for these variables per region.

### example

With the example module and instance of module defined below, we would get 2 itterations of the resource block in the module. 

Thats becuase in the (Instance of Module example)[#instance-of-module-example]'s variable launch_template.regions, we have 2 key => values defining region specific variables, us-east-1 and us-east-2.

#### module example

The module will create a `local.all_resources` variable list(object) which does a loop over `var.launch_template.regions` to get all the region specific variables. Then in the resource `aws_launch_template` it does a for_each loop of this local.all_resources variable to determine how many instances of this resource will be created. In each loop, the global configuration variables will be sourced from var.launch_template whereas the region specific configuration variables will be sourced from the current index of the for_each loop on local.all_resources.

```hcl
locals {
  # list(object) for region specific variables
  all_resources = [
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
    for index, region_data in local.all_resources: region_data.region => region_data
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

Calling the module to create the EC2 Launch template in us-east-1 and us-east-2

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

#### local.all_resources
This is what the variable `local.all_resources` looks like after it does the loop over var.launch_template.regions.

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
This is what the for_each looks like under `aws_launch_template.this` after it does the loop over local.all_resources.

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

#### Why v0.0.2 Would not work

So far the module looks very promising. We're utilizing a single aws_launch_template resource block and a for_each loop over local.all_resources determines how many copies and to which region the copies are getting created in.

If you havn't caught the one thing thats blocking this single resource approach then here it is, **PROVIDER ALIAS** !

So it turns out, theres no dynamic way of setting the provider on each loop of the resource. When we want to create a resource in a different region than the one where our base infrastructure is being created, we have to define a provider alias for that second region, and call it in that resource block.

For Example: If we wanted to modify the module's resource aws_launch_template.this to support multi-region, at the bottom we would want some sort of logic to dynamically use that regions provider alias. 

* In the example shown below, the `provider` is theoretically checking is the current resource for_each loop is for us-east-1:
    - if it is, then don't set the provider configuration, it will use the modules default provider which happens to be for us-east-1 already.
    - if it's NOT, then set the provider and use the provider alias for the current region

So looking at the provider alias being passed to the module in [Instance of Module example](#instance-of-module-example) we can see the alias are named as `aws.us-east-2`, `aws.us-west-1`, `aws.us-west-2`. For resource loops other than us-east-1, the provider config would have to be defined with one of these values but that can't be set dynamically like in the example below.

This example dynamic provider configuration is invalid terraform syntax. Using a provider alias is normally like this: `aws.<Provider_Alias_Name>` but `aws."${each.value.region}"` does not get interpreted as such due to the error of string concat to `aws.`

```hcl
resource "aws_launch_template" "this" {
  for_each = {
    for index, region_data in local.all_resources: region_data.region => region_data
  }

  ...

  dynamic "tag_specifications" {
    for_each = each.value.region_regional_tags != {} ? [1] : []
    content {
      resource_type = var.launch_template.tag_specifications.resource_type
      tags = each.value.region_regional_tags
    }
  }

  tags = local.tags 

  provider = each.value.region == "us-east-1" ? null : aws."${each.value.region}"
}
```

## v0.0.3

This is why in v0.0.3 we kept the same [Instance of Module example](#instance-of-module-example) but in the module itself, we had to create 4 aws_launch_template resource blocks, one for each region. In each region specific resource block we first check if a key in local.all_resources exists with that region name, if so, then create the resource, otherwise don't create that resource for that region. 



### Usage

### New Module aws_launch_template resources

```hcl
locals {
  # list(object) for region specific variables
  all_resources = [
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

resource "aws_launch_template" "us_east_1" {
  for_each = { for region_name, region_data in local.all_resources : region_name => region_data if region_name == "us-east-1" }
  
  # no provider config needed for us-east-1
  name_prefix = "${var.launch_template.name_prefix}-"

  ...
  
  image_id = each.value.region_image_id
  
  ...
}

resource "aws_launch_template" "us_east_2" {
  for_each = { for region_name, region_data in local.all_resources : region_name => region_data if region_name == "us-east-2" }
  
  provider = aws.us-east-2
  name_prefix = "${var.launch_template.name_prefix}-"

  ...
  
  image_id = each.value.region_image_id
  
  ...
}
```

### Same instance of module example
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
