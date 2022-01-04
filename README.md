Terraform config for quickly spinning up Multipass VMs. It builds on the efforts of [this](https://github.com/Nyariki/Terraform-Multipass.git) project. 

This setup allows us to define a [cloud-init](https://help.ubuntu.com/community/CloudInit) template, which will help us add such things as users, groups, startup commands, ssh keys for access, etc. to the VMs.  

## Requirements
1. [Terraform](https://www.terraform.io/downloads). 
2. [Groovy](https://groovy-lang.org/install.html). 
3. [Multipass](https://multipass.run/). 
4. `SSH-Keygen` tool, accessible from your console. 

## Modules
### 1. Key
The [key](/multipass/key/key.tf) module manages the SSH keys. For every new VM, a SSH public-private key pair is generated. 

The `ssh_key` resource wraps up calls to a [script](multipass/key/scripts/operations.groovy) that creates, reads and deletes the key, according to the resource lifecycle.

### 2. Config
The [config](/multipass/config/config.tf) module provides the cloud-init yaml content. It reads from the [template](multipass/config/cloud_init_template.yaml) file, replaces some placeholders in the template with values from the module, then returns valid cloud-init content. 

### 3. Multipass
The [multipass](/multipass/main.tf) module manages the VM, allowing the name, memory, cpus and disk-space to be customized. 

The `vm` resource wraps up calls to a [script](multipass/scripts/operations.groovy) that creates, reads and deletes the vm, according to the resource lifecycle.

## Testing
A vm created can be accessed via SSH on the console, for example: 
```console
ssh -i multipass/key/keys/id_rsa_test-vm-0 -oStrictHostKeyChecking=no ubuntu@192.168.64.19 
```

ToDo: Use Terraform to spin up a K8S cluster entirely on this config.
