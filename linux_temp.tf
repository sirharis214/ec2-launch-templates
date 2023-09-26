module "linux_temp" {
  source = "./modules/linux_temp"

  linux_temp = {
    name_prefix = "main-linux-temp"

    iam_instance_profile = {
      name = "main-ec2-profile"
    }

    image_id = "ami-00c6177f250e07ec1" # Amazon Linux 2
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
        OS = "linux"
      }
    }
  }
  project_tags = local.tags
}
