module "windows_temp" {
  source = "./modules/launch_template"

  launch_template = {
    name_prefix = "main-windows-temp"
    os          = "windows"

    iam_instance_profile = {
      name = "main-ec2-profile"
    }

    image_id = "ami-0be0e902919675894" # Microsoft Windows Server 2022 Base
    key_name = "main-us-east-1"

    network_interfaces = {
      security_groups = [
        "sg-077d89eca08b13f9e", # main-sg
      ]
      subnet_id = "subnet-038c1a5affe144076" # main-public-subnet-1
    }

    placement = {
      availability_zone = "us-east-1a"
    }

    tag_specifications = {
      tags = {
        OS = "windows"
      }
    }
  }
  project_tags = local.tags
}
