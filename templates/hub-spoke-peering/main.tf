variable "virtual_network_hub" {}
variable "virtual_network_spoke" {}
variable "vnet_peering_peering" {}
variable "route_table_rt" {}
variable "network_security_group_nsg" {}

module "virtual_network_hub" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/virtual-network?ref=virtual-network/v1.0.0"

  resource_group_name = var.virtual_network_hub.resource_group_name
  location            = var.virtual_network_hub.location
  name                = var.virtual_network_hub.name
  tags                = var.virtual_network_hub.tags
  address_space       = var.virtual_network_hub.address_space
  subnets             = var.virtual_network_hub.subnets
}
module "virtual_network_spoke" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/virtual-network?ref=virtual-network/v1.0.0"

  resource_group_name             = var.virtual_network_spoke.resource_group_name
  location                        = var.virtual_network_spoke.location
  name                            = var.virtual_network_spoke.name
  tags                            = var.virtual_network_spoke.tags
  address_space                   = var.virtual_network_spoke.address_space
  subnets                         = var.virtual_network_spoke.subnets
  subnet_route_table_associations = { "workload" = module.route_table_rt.id }
  subnet_nsg_associations         = { "workload" = module.network_security_group_nsg.id }
}
module "vnet_peering_peering" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/vnet-peering?ref=vnet-peering/v1.0.0"

  name                                       = var.vnet_peering_peering.name
  tags                                       = var.vnet_peering_peering.tags
  virtual_network_resource_group_name        = element(split("/", module.virtual_network_hub.id), 4)
  virtual_network_name                       = element(split("/", module.virtual_network_hub.id), length(split("/", module.virtual_network_hub.id)) - 1)
  remote_virtual_network_name                = element(split("/", module.virtual_network_spoke.id), length(split("/", module.virtual_network_spoke.id)) - 1)
  remote_virtual_network_resource_group_name = element(split("/", module.virtual_network_spoke.id), 4)
  virtual_network_id                         = module.virtual_network_hub.id
  remote_virtual_network_id                  = module.virtual_network_spoke.id
}
module "route_table_rt" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/route-table?ref=route-table/v1.2.0"

  resource_group_name = var.route_table_rt.resource_group_name
  location            = var.route_table_rt.location
  name                = var.route_table_rt.name
  tags                = var.route_table_rt.tags
}
module "network_security_group_nsg" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/network-security-group?ref=network-security-group/v1.3.0"

  resource_group_name = var.network_security_group_nsg.resource_group_name
  location            = var.network_security_group_nsg.location
  name                = var.network_security_group_nsg.name
  tags                = var.network_security_group_nsg.tags
}

output "virtual_network_hub_id" {
  value = module.virtual_network_hub.id
}
output "virtual_network_hub_name" {
  value = module.virtual_network_hub.name
}
output "virtual_network_spoke_id" {
  value = module.virtual_network_spoke.id
}
output "virtual_network_spoke_name" {
  value = module.virtual_network_spoke.name
}
output "vnet_peering_peering_id" {
  value = module.vnet_peering_peering.id
}
output "vnet_peering_peering_name" {
  value = module.vnet_peering_peering.name
}
output "route_table_rt_id" {
  value = module.route_table_rt.id
}
output "route_table_rt_name" {
  value = module.route_table_rt.name
}
output "network_security_group_nsg_id" {
  value = module.network_security_group_nsg.id
}
output "network_security_group_nsg_name" {
  value = module.network_security_group_nsg.name
}
