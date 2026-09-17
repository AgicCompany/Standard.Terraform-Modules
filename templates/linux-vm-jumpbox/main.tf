variable "virtual_network_vnet" {}
variable "network_security_group_nsg" {}
variable "linux_virtual_machine_vm" {}
variable "bastion_bastion" {}

module "virtual_network_vnet" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/virtual-network?ref=virtual-network/v1.0.0"

  resource_group_name     = var.virtual_network_vnet.resource_group_name
  location                = var.virtual_network_vnet.location
  name                    = var.virtual_network_vnet.name
  tags                    = var.virtual_network_vnet.tags
  address_space           = var.virtual_network_vnet.address_space
  subnets                 = var.virtual_network_vnet.subnets
  subnet_nsg_associations = { "vm" = module.network_security_group_nsg.id }
}
module "network_security_group_nsg" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/network-security-group?ref=network-security-group/v1.3.0"

  resource_group_name = var.network_security_group_nsg.resource_group_name
  location            = var.network_security_group_nsg.location
  name                = var.network_security_group_nsg.name
  tags                = var.network_security_group_nsg.tags
}
module "linux_virtual_machine_vm" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/linux-virtual-machine?ref=linux-virtual-machine/v1.3.0"

  resource_group_name  = var.linux_virtual_machine_vm.resource_group_name
  location             = var.linux_virtual_machine_vm.location
  name                 = var.linux_virtual_machine_vm.name
  tags                 = var.linux_virtual_machine_vm.tags
  size                 = var.linux_virtual_machine_vm.size
  admin_username       = var.linux_virtual_machine_vm.admin_username
  admin_ssh_public_key = var.linux_virtual_machine_vm.admin_ssh_public_key
  subnet_id            = module.virtual_network_vnet.subnet_ids["vm"]
}
module "bastion_bastion" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/bastion?ref=bastion/v1.0.0"

  resource_group_name = var.bastion_bastion.resource_group_name
  location            = var.bastion_bastion.location
  name                = var.bastion_bastion.name
  tags                = var.bastion_bastion.tags
  subnet_id           = module.virtual_network_vnet.subnet_ids["AzureBastionSubnet"]
}

output "virtual_network_vnet_id" {
  value = module.virtual_network_vnet.id
}
output "virtual_network_vnet_name" {
  value = module.virtual_network_vnet.name
}
output "network_security_group_nsg_id" {
  value = module.network_security_group_nsg.id
}
output "network_security_group_nsg_name" {
  value = module.network_security_group_nsg.name
}
output "linux_virtual_machine_vm_id" {
  value = module.linux_virtual_machine_vm.id
}
output "linux_virtual_machine_vm_name" {
  value = module.linux_virtual_machine_vm.name
}
output "linux_virtual_machine_vm_private_ip_address" {
  value = module.linux_virtual_machine_vm.private_ip_address
}
output "linux_virtual_machine_vm_public_ip_address" {
  value = module.linux_virtual_machine_vm.public_ip_address
}
output "bastion_bastion_id" {
  value = module.bastion_bastion.id
}
output "bastion_bastion_dns_name" {
  value = module.bastion_bastion.dns_name
}
output "bastion_bastion_public_ip_address" {
  value = module.bastion_bastion.public_ip_address
}
