module "linux_temp" {
  source = "./modules/launch_template"

  launch_template = {
    name_prefix = "main-linux-temp"

    iam_instance_profile = {
      name = "main-ec2-profile"
    }

    tag_specifications = {
      tags = {
        OS    = "linux"
        Owner = "Haris N"
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
