variable "app_service_plan_plan" {}
variable "linux_web_app_webapp" {}
variable "postgresql_flexible_server_db" {}
variable "redis_cache_cache" {}
variable "key_vault_kv" {}
variable "log_analytics_workspace_logs" {}
variable "application_insights_insights" {}

module "app_service_plan_plan" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/app-service-plan?ref=app-service-plan/v1.0.1"

  resource_group_name = var.app_service_plan_plan.resource_group_name
  location            = var.app_service_plan_plan.location
  name                = var.app_service_plan_plan.name
  tags                = var.app_service_plan_plan.tags
  sku_name            = var.app_service_plan_plan.sku_name
}
module "linux_web_app_webapp" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/linux-web-app?ref=linux-web-app/v2.2.1"

  resource_group_name     = var.linux_web_app_webapp.resource_group_name
  location                = var.linux_web_app_webapp.location
  name                    = var.linux_web_app_webapp.name
  tags                    = var.linux_web_app_webapp.tags
  enable_private_endpoint = var.linux_web_app_webapp.enable_private_endpoint
  service_plan_id         = module.app_service_plan_plan.id
}
module "postgresql_flexible_server_db" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/postgresql-flexible-server?ref=postgresql-flexible-server/v5.0.3"

  resource_group_name     = var.postgresql_flexible_server_db.resource_group_name
  location                = var.postgresql_flexible_server_db.location
  name                    = var.postgresql_flexible_server_db.name
  tags                    = var.postgresql_flexible_server_db.tags
  enable_entra_auth       = var.postgresql_flexible_server_db.enable_entra_auth
  enable_password_auth    = var.postgresql_flexible_server_db.enable_password_auth
  administrator_login     = var.postgresql_flexible_server_db.administrator_login
  administrator_password  = var.postgresql_flexible_server_db.administrator_password
  enable_private_endpoint = var.postgresql_flexible_server_db.enable_private_endpoint
}
module "redis_cache_cache" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/redis-cache?ref=redis-cache/v4.0.2"

  resource_group_name     = var.redis_cache_cache.resource_group_name
  location                = var.redis_cache_cache.location
  name                    = var.redis_cache_cache.name
  tags                    = var.redis_cache_cache.tags
  enable_private_endpoint = var.redis_cache_cache.enable_private_endpoint
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
module "application_insights_insights" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/application-insights?ref=application-insights/v2.1.0"

  resource_group_name = var.application_insights_insights.resource_group_name
  location            = var.application_insights_insights.location
  name                = var.application_insights_insights.name
  tags                = var.application_insights_insights.tags
  workspace_id        = module.log_analytics_workspace_logs.id
}

output "app_service_plan_plan_id" {
  value = module.app_service_plan_plan.id
}
output "app_service_plan_plan_name" {
  value = module.app_service_plan_plan.name
}
output "linux_web_app_webapp_id" {
  value = module.linux_web_app_webapp.id
}
output "linux_web_app_webapp_name" {
  value = module.linux_web_app_webapp.name
}
output "linux_web_app_webapp_default_hostname" {
  value = module.linux_web_app_webapp.default_hostname
}
output "linux_web_app_webapp_private_ip_address" {
  value = module.linux_web_app_webapp.private_ip_address
}
output "postgresql_flexible_server_db_id" {
  value = module.postgresql_flexible_server_db.id
}
output "postgresql_flexible_server_db_name" {
  value = module.postgresql_flexible_server_db.name
}
output "postgresql_flexible_server_db_fqdn" {
  value = module.postgresql_flexible_server_db.fqdn
}
output "postgresql_flexible_server_db_private_ip_address" {
  value = module.postgresql_flexible_server_db.private_ip_address
}
output "redis_cache_cache_id" {
  value = module.redis_cache_cache.id
}
output "redis_cache_cache_name" {
  value = module.redis_cache_cache.name
}
output "redis_cache_cache_hostname" {
  value = module.redis_cache_cache.hostname
}
output "redis_cache_cache_ssl_port" {
  value = module.redis_cache_cache.ssl_port
}
output "redis_cache_cache_private_ip_address" {
  value = module.redis_cache_cache.private_ip_address
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
output "application_insights_insights_id" {
  value = module.application_insights_insights.id
}
output "application_insights_insights_app_id" {
  value = module.application_insights_insights.app_id
}
