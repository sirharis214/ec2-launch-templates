locals {
  module_tags = {
    module_name = join("/", compact([
      lookup(var.project_tags, "module_name", null),
      "ec2-launch-templates",
      ])
    )
    module_repo = "https://github.com/sirharis214/ec2-launch-templates"
  }

  tags = merge(var.project_tags, local.module_tags)
}
