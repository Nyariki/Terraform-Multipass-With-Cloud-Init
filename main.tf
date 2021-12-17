# Demo to spin up 5 Multipass Ubuntu VMs

module "multipass_vms" {
  source = "./multipass"

  count  = 2

  name   = "test-vm-${count.index}"
  
}