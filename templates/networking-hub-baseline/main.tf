variable "virtual_network_vnet" {}
variable "network_security_group_nsg" {}
variable "route_table_rt" {}
variable "nat_gateway_nat" {}
variable "bastion_bastion" {}
variable "private_dns_zone_pdns" {}

module "virtual_network_vnet" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/virtual-network?ref=virtual-network/v1.0.0"

  resource_group_name = var.virtual_network_vnet.resource_group_name
  location            = var.virtual_network_vnet.location
  name                = var.virtual_network_vnet.name
  tags                = var.virtual_network_vnet.tags
  address_space       = var.virtual_network_vnet.address_space
  subnets             = var.virtual_network_vnet.subnets
}
module "network_security_group_nsg" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/network-security-group?ref=network-security-group/v1.3.0"

  resource_group_name = var.network_security_group_nsg.resource_group_name
  location            = var.network_security_group_nsg.location
  name                = var.network_security_group_nsg.name
  tags                = var.network_security_group_nsg.tags
}
module "route_table_rt" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/route-table?ref=route-table/v1.2.0"

  resource_group_name = var.route_table_rt.resource_group_name
  location            = var.route_table_rt.location
  name                = var.route_table_rt.name
  tags                = var.route_table_rt.tags
}
module "nat_gateway_nat" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/nat-gateway?ref=nat-gateway/v1.0.0"

  resource_group_name = var.nat_gateway_nat.resource_group_name
  location            = var.nat_gateway_nat.location
  name                = var.nat_gateway_nat.name
  tags                = var.nat_gateway_nat.tags
}
module "bastion_bastion" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/bastion?ref=bastion/v1.0.0"

  resource_group_name = var.bastion_bastion.resource_group_name
  location            = var.bastion_bastion.location
  name                = var.bastion_bastion.name
  tags                = var.bastion_bastion.tags
  subnet_id           = module.virtual_network_vnet.subnet_ids["AzureBastionSubnet"]
}
module "private_dns_zone_pdns" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/private-dns-zone?ref=private-dns-zone/v1.0.0"

  resource_group_name = var.private_dns_zone_pdns.resource_group_name
  name                = var.private_dns_zone_pdns.name
  tags                = var.private_dns_zone_pdns.tags
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
output "route_table_rt_id" {
  value = module.route_table_rt.id
}
output "route_table_rt_name" {
  value = module.route_table_rt.name
}
output "nat_gateway_nat_id" {
  value = module.nat_gateway_nat.id
}
output "nat_gateway_nat_name" {
  value = module.nat_gateway_nat.name
}
output "nat_gateway_nat_public_ip_address" {
  value = module.nat_gateway_nat.public_ip_address
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
output "private_dns_zone_pdns_id" {
  value = module.private_dns_zone_pdns.id
}
output "private_dns_zone_pdns_name" {
  value = module.private_dns_zone_pdns.name
}
