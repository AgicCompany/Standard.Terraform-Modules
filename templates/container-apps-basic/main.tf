variable "log_analytics_workspace_logs" {}
variable "container_app_environment_env" {}
variable "container_app_app" {}
variable "container_registry_acr" {}
variable "user_assigned_identity_uami" {}
variable "virtual_network_vnet" {}

module "log_analytics_workspace_logs" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/log-analytics-workspace?ref=log-analytics-workspace/v1.0.0"

  resource_group_name = var.log_analytics_workspace_logs.resource_group_name
  location            = var.log_analytics_workspace_logs.location
  name                = var.log_analytics_workspace_logs.name
  tags                = var.log_analytics_workspace_logs.tags
}
module "container_app_environment_env" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/container-app-environment?ref=container-app-environment/v2.0.1"

  resource_group_name        = var.container_app_environment_env.resource_group_name
  location                   = var.container_app_environment_env.location
  name                       = var.container_app_environment_env.name
  tags                       = var.container_app_environment_env.tags
  log_analytics_workspace_id = module.log_analytics_workspace_logs.id
  infrastructure_subnet_id   = module.virtual_network_vnet.subnet_ids["aca"]
}
module "container_app_app" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/container-app?ref=container-app/v1.3.1"

  resource_group_name          = var.container_app_app.resource_group_name
  name                         = var.container_app_app.name
  tags                         = var.container_app_app.tags
  container                    = var.container_app_app.container
  container_app_environment_id = module.container_app_environment_env.id
  user_assigned_identity_ids   = [module.user_assigned_identity_uami.id]
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
module "virtual_network_vnet" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/virtual-network?ref=virtual-network/v1.0.0"

  resource_group_name = var.virtual_network_vnet.resource_group_name
  location            = var.virtual_network_vnet.location
  name                = var.virtual_network_vnet.name
  tags                = var.virtual_network_vnet.tags
  address_space       = var.virtual_network_vnet.address_space
  subnets             = var.virtual_network_vnet.subnets
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
output "container_app_environment_env_id" {
  value = module.container_app_environment_env.id
}
output "container_app_environment_env_name" {
  value = module.container_app_environment_env.name
}
output "container_app_environment_env_default_domain" {
  value = module.container_app_environment_env.default_domain
}
output "container_app_environment_env_static_ip_address" {
  value = module.container_app_environment_env.static_ip_address
}
output "container_app_app_id" {
  value = module.container_app_app.id
}
output "container_app_app_name" {
  value = module.container_app_app.name
}
output "container_app_app_latest_revision_fqdn" {
  value = module.container_app_app.latest_revision_fqdn
}
output "container_app_app_latest_revision_name" {
  value = module.container_app_app.latest_revision_name
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
output "virtual_network_vnet_id" {
  value = module.virtual_network_vnet.id
}
output "virtual_network_vnet_name" {
  value = module.virtual_network_vnet.name
}
