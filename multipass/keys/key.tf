variable "name" {
  type = string
  description = "Name of VM"
}

locals {
  ssh_key_path        = "keys/"
  ssh_key             = "${local.ssh_key_path}id_rsa_${var.name}"
  ssh_key_json        = jsonencode({
    "\"public_key\""  = "${local.ssh_key}.pub"
  })
}

resource "null_resource"  "ssh_keys"{
  depends_on = [null_resource.generate_ssh_keys]
}

resource "null_resource" "generate_ssh_keys" {
  triggers = {
    ssh_key = local.ssh_key
  }

  provisioner "local-exec" {
    command     = "mkdir -p ${local.ssh_key_path} && ssh-keygen -t rsa -b 4096 -f ${local.ssh_key} -N '' -q"
    working_dir = path.module
  }
  provisioner "local-exec" {
    when        = destroy
    command     = "rm -rf ${self.triggers.ssh_key}*"
    working_dir = path.module
  }
}

output "public_key" {
  value = local.ssh_key_json
}