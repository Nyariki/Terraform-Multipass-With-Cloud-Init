terraform {
  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "1.7.10"
    }
  }
}

variable "name" {
  type        = string
  description = "Name of VM"
}

locals {
  ssh_key_path   = "${path.module}/keys/"
  ssh_key        = "${local.ssh_key_path}id_rsa_${var.name}"
  ssh_public_key = "${local.ssh_key}.pub"
}

resource "shell_script" "ssh_key" {
  lifecycle_commands {
    create = "groovy ${path.module}/scripts/operations.groovy createKey ${local.ssh_key_path} ${local.ssh_key}"
    read   = "groovy ${path.module}/scripts/operations.groovy getPublicKey ${local.ssh_public_key}"
    delete = "groovy ${path.module}/scripts/operations.groovy deleteKey ${local.ssh_key}"
  }
}

output "key" {
  value      = shell_script.ssh_key.output
  depends_on = [
    shell_script.ssh_keys
  ]

}