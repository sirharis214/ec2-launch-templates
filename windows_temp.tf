module "windows_temp" {
  source = "./modules/launch_template"

  launch_template = {
    name_prefix = "main-windows-temp"
    os          = "windows"

    iam_instance_profile = {
      name = "main-ec2-profile"
    }

    tag_specifications = {
      tags = {
        OS = "windows"
      }
    }

    regions = {
      us-east-1 = {
        image_id = "ami-0be0e902919675894" # Microsoft Windows Server 2022 Base
        key_name = "main-us-east-1"
        network_interfaces = {
          security_groups = [
            "sg-077d89eca08b13f9e", # main-sg
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
