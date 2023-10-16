# module "linux_temp" {
#   source = "./modules/launch_template"

#   launch_template = {
#     name_prefix = "main-linux-temp"

#     iam_instance_profile = {
#       name = "main-ec2-profile"
#     }

#     image_id = "ami-00c6177f250e07ec1" # Amazon Linux 2
#     key_name = "main-us-east-1"

#     network_interfaces = {
#       security_groups = [
#         "sg-077d89eca08b13f9e", # main-sg
#       ]
#       subnet_id = "subnet-038c1a5affe144076" # main-public-subnet-1
#     }

#     tag_specifications = {
#       tags = {
#         OS = "linux"
#       }
#     }

#     multi_region = {
#       enable  = true
#       regions = {
#         us-east-2 = {
#           security_groups = [
#             "sg-041b3e39b881e6063" # us-east-2 default
#           ]
#           subnet_id       = "subnet-06c63da68c902e819" # us-east-2a
#           image_id        = "ami-0aec300fa613b1c92"    # amazon linux 2
#         }
#       } 
#     }
#   }
#   project_tags = local.tags
#   # providers = {
#   #   aws           = aws
#   #   aws.us-east-2 = aws.us-east-2
#   #   aws.us-west-1 = aws.us-west-1
#   #   aws.us-west-2 = aws.us-west-2
#   # }
# }
