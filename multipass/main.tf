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

variable "mem" {
  type        = string
  default     = "1g"
  description = "Memory of VM"
}

variable "cpus" {
  type        = number
  default     = 2
  description = "CPUs in VM"
}

variable "disk" {
  type        = string
  default     = "10G"
  description = "Storage in VM"
}

module "config" {
  source = "./config"
  name   = var.name
}

resource "shell_script" "vm" {
  lifecycle_commands {
    create = "groovy ${path.module}/scripts/operations.groovy createVm ${var.name} ${var.mem} ${var.cpus} ${var.disk} ${module.config.cloud_init}"
    read   = "groovy ${path.module}/scripts/operations.groovy getVm ${var.name}"
    delete = "groovy ${path.module}/scripts/operations.groovy deleteVm ${var.name}"
  }
}



