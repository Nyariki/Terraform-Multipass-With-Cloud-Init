variable "name" {
  type = string
  description = "Name of VM"
}

locals {
  cloud_init_template = "${path.module}/cloud_init_template.yaml"
  cloud_init_path     = "${path.module}/configs"
  cloud_init_file     = "${local.cloud_init_path}/cloud_init_${var.name}.yaml"
  public_key = try (module.keys.key["public_key"], "")
}

module "keys" {
  source = "../key"
  name = var.name
}

data "template_file" "config" {
  template = file(local.cloud_init_template)
  vars = {
    name           = var.name
    password       = "ubuntu",
    ssh_public_key = local.public_key
  }

  depends_on = [module.keys]
}

output "cloud_init" {
  value = try (base64encode(data.template_file.config.rendered), "")
}
