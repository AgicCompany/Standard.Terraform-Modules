variable "virtual_network_vnet" {}
variable "aks_aks" {}
variable "aks_node_pool_userpool" {}
variable "container_registry_acr" {}
variable "user_assigned_identity_uami" {}
variable "key_vault_kv" {}
variable "log_analytics_workspace_logs" {}

module "virtual_network_vnet" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/virtual-network?ref=virtual-network/v1.0.0"

  resource_group_name = var.virtual_network_vnet.resource_group_name
  location            = var.virtual_network_vnet.location
  name                = var.virtual_network_vnet.name
  tags                = var.virtual_network_vnet.tags
  address_space       = var.virtual_network_vnet.address_space
  subnets             = var.virtual_network_vnet.subnets
}
module "aks_aks" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/aks?ref=aks/v4.1.2"

  resource_group_name             = var.aks_aks.resource_group_name
  location                        = var.aks_aks.location
  name                            = var.aks_aks.name
  tags                            = var.aks_aks.tags
  dns_prefix                      = var.aks_aks.dns_prefix
  maintenance_window              = var.aks_aks.maintenance_window
  maintenance_window_auto_upgrade = var.aks_aks.maintenance_window_auto_upgrade
  maintenance_window_node_os      = var.aks_aks.maintenance_window_node_os
  node_resource_group_name        = var.aks_aks.node_resource_group_name
  default_node_pool               = merge(var.aks_aks.default_node_pool, { vnet_subnet_id = module.virtual_network_vnet.subnet_ids["aks"] })
}
module "aks_node_pool_userpool" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/aks-node-pool?ref=aks-node-pool/v2.0.0"

  node_pools            = merge(var.aks_node_pool_userpool.node_pools, { "user" = merge(try(var.aks_node_pool_userpool.node_pools["user"], {}), { vnet_subnet_id = module.virtual_network_vnet.subnet_ids["aks"] }) })
  kubernetes_cluster_id = module.aks_aks.id
}
module "container_registry_acr" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/container-registry?ref=container-registry/v2.2.1"

  resource_group_name     = var.container_registry_acr.resource_group_name
  location                = var.container_registry_acr.location
  name                    = var.container_registry_acr.name
  tags                    = var.container_registry_acr.tags
  enable_private_endpoint = var.container_registry_acr.enable_private_endpoint
}
module "user_assigned_identity_uami" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/user-assigned-identity?ref=user-assigned-identity/v1.0.0"

  resource_group_name = var.user_assigned_identity_uami.resource_group_name
  location            = var.user_assigned_identity_uami.location
  name                = var.user_assigned_identity_uami.name
  tags                = var.user_assigned_identity_uami.tags
}
module "key_vault_kv" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/key-vault?ref=key-vault/v2.1.1"

  resource_group_name     = var.key_vault_kv.resource_group_name
  location                = var.key_vault_kv.location
  name                    = var.key_vault_kv.name
  tags                    = var.key_vault_kv.tags
  enable_private_endpoint = var.key_vault_kv.enable_private_endpoint
}
module "log_analytics_workspace_logs" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/log-analytics-workspace?ref=log-analytics-workspace/v1.0.0"

  resource_group_name = var.log_analytics_workspace_logs.resource_group_name
  location            = var.log_analytics_workspace_logs.location
  name                = var.log_analytics_workspace_logs.name
  tags                = var.log_analytics_workspace_logs.tags
}

output "virtual_network_vnet_id" {
  value = module.virtual_network_vnet.id
}
output "virtual_network_vnet_name" {
  value = module.virtual_network_vnet.name
}
output "aks_aks_id" {
  value = module.aks_aks.id
}
output "aks_aks_name" {
  value = module.aks_aks.name
}
output "aks_aks_fqdn" {
  value = module.aks_aks.fqdn
}
output "aks_aks_private_fqdn" {
  value = module.aks_aks.private_fqdn
}
output "aks_aks_node_resource_group" {
  value = module.aks_aks.node_resource_group
}
output "aks_node_pool_userpool_node_pool_ids" {
  value = module.aks_node_pool_userpool.node_pool_ids
}
output "container_registry_acr_id" {
  value = module.container_registry_acr.id
}
output "container_registry_acr_name" {
  value = module.container_registry_acr.name
}
output "container_registry_acr_login_server" {
  value = module.container_registry_acr.login_server
}
output "container_registry_acr_private_ip_address" {
  value = module.container_registry_acr.private_ip_address
}
output "user_assigned_identity_uami_id" {
  value = module.user_assigned_identity_uami.id
}
output "user_assigned_identity_uami_principal_id" {
  value = module.user_assigned_identity_uami.principal_id
}
output "key_vault_kv_id" {
  value = module.key_vault_kv.id
}
output "key_vault_kv_name" {
  value = module.key_vault_kv.name
}
output "key_vault_kv_vault_uri" {
  value = module.key_vault_kv.vault_uri
}
output "key_vault_kv_private_ip_address" {
  value = module.key_vault_kv.private_ip_address
}
output "log_analytics_workspace_logs_id" {
  value = module.log_analytics_workspace_logs.id
}
output "log_analytics_workspace_logs_name" {
  value = module.log_analytics_workspace_logs.name
}
output "log_analytics_workspace_logs_workspace_id" {
  value = module.log_analytics_workspace_logs.workspace_id
}
