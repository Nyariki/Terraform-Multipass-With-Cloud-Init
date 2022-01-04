# Demo to spin up 5 Multipass Ubuntu VMs

# list of hosts to be created
locals {
  vms = 3
}

module "multipass_vms" {
  source = "./multipass"

  count = local.vms

  name = "test-vm-${count.index}"

}