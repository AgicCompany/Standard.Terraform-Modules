variable "app_service_plan_plan" {}
variable "linux_web_app_webapp" {}
variable "mssql_server_sql" {}
variable "mssql_database_db" {}
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
module "mssql_server_sql" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/mssql-server?ref=mssql-server/v3.1.2"

  resource_group_name     = var.mssql_server_sql.resource_group_name
  location                = var.mssql_server_sql.location
  name                    = var.mssql_server_sql.name
  tags                    = var.mssql_server_sql.tags
  azuread_administrator   = var.mssql_server_sql.azuread_administrator
  enable_private_endpoint = var.mssql_server_sql.enable_private_endpoint
}
module "mssql_database_db" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/mssql-database?ref=mssql-database/v1.3.1"

  name      = var.mssql_database_db.name
  tags      = var.mssql_database_db.tags
  server_id = module.mssql_server_sql.id
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
output "mssql_server_sql_id" {
  value = module.mssql_server_sql.id
}
output "mssql_server_sql_name" {
  value = module.mssql_server_sql.name
}
output "mssql_server_sql_fully_qualified_domain_name" {
  value = module.mssql_server_sql.fully_qualified_domain_name
}
output "mssql_server_sql_private_ip_address" {
  value = module.mssql_server_sql.private_ip_address
}
output "mssql_database_db_id" {
  value = module.mssql_database_db.id
}
output "mssql_database_db_name" {
  value = module.mssql_database_db.name
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
