variable "static_web_app_swa" {}
variable "app_service_plan_plan" {}
variable "storage_account_storage" {}
variable "function_app_flex_api" {}
variable "log_analytics_workspace_logs" {}
variable "application_insights_insights" {}

module "static_web_app_swa" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/static-web-app?ref=static-web-app/v3.0.0"

  resource_group_name             = var.static_web_app_swa.resource_group_name
  location                        = var.static_web_app_swa.location
  name                            = var.static_web_app_swa.name
  tags                            = var.static_web_app_swa.tags
  private_endpoint_name           = var.static_web_app_swa.private_endpoint_name
  private_service_connection_name = var.static_web_app_swa.private_service_connection_name
  private_endpoint_nic_name       = var.static_web_app_swa.private_endpoint_nic_name
  enable_private_endpoint         = var.static_web_app_swa.enable_private_endpoint
}
module "app_service_plan_plan" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/app-service-plan?ref=app-service-plan/v1.0.1"

  resource_group_name     = var.app_service_plan_plan.resource_group_name
  location                = var.app_service_plan_plan.location
  name                    = var.app_service_plan_plan.name
  tags                    = var.app_service_plan_plan.tags
  os_type                 = var.app_service_plan_plan.os_type
  sku_name                = var.app_service_plan_plan.sku_name
  worker_count            = var.app_service_plan_plan.worker_count
  enable_zone_redundancy  = var.app_service_plan_plan.enable_zone_redundancy
  enable_per_site_scaling = var.app_service_plan_plan.enable_per_site_scaling
}
module "storage_account_storage" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/storage-account?ref=storage-account/v3.2.1"

  resource_group_name                  = var.storage_account_storage.resource_group_name
  location                             = var.storage_account_storage.location
  name                                 = var.storage_account_storage.name
  tags                                 = var.storage_account_storage.tags
  account_tier                         = var.storage_account_storage.account_tier
  account_replication_type             = var.storage_account_storage.account_replication_type
  account_kind                         = var.storage_account_storage.account_kind
  access_tier                          = var.storage_account_storage.access_tier
  allow_nested_items_to_be_public      = var.storage_account_storage.allow_nested_items_to_be_public
  shared_access_key_enabled            = var.storage_account_storage.shared_access_key_enabled
  enable_public_access                 = var.storage_account_storage.enable_public_access
  enable_private_endpoint              = var.storage_account_storage.enable_private_endpoint
  enable_blob_private_endpoint         = var.storage_account_storage.enable_blob_private_endpoint
  enable_file_private_endpoint         = var.storage_account_storage.enable_file_private_endpoint
  enable_table_private_endpoint        = var.storage_account_storage.enable_table_private_endpoint
  enable_queue_private_endpoint        = var.storage_account_storage.enable_queue_private_endpoint
  enable_versioning                    = var.storage_account_storage.enable_versioning
  enable_blob_soft_delete              = var.storage_account_storage.enable_blob_soft_delete
  blob_soft_delete_retention_days      = var.storage_account_storage.blob_soft_delete_retention_days
  enable_container_soft_delete         = var.storage_account_storage.enable_container_soft_delete
  container_soft_delete_retention_days = var.storage_account_storage.container_soft_delete_retention_days
}
module "function_app_flex_api" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/function-app-flex?ref=function-app-flex/v2.0.1"

  resource_group_name                            = var.function_app_flex_api.resource_group_name
  location                                       = var.function_app_flex_api.location
  name                                           = var.function_app_flex_api.name
  tags                                           = var.function_app_flex_api.tags
  runtime_name                                   = var.function_app_flex_api.runtime_name
  runtime_version                                = var.function_app_flex_api.runtime_version
  storage_authentication_type                    = var.function_app_flex_api.storage_authentication_type
  storage_container_type                         = var.function_app_flex_api.storage_container_type
  instance_memory_in_mb                          = var.function_app_flex_api.instance_memory_in_mb
  maximum_instance_count                         = var.function_app_flex_api.maximum_instance_count
  identity_type                                  = var.function_app_flex_api.identity_type
  https_only                                     = var.function_app_flex_api.https_only
  client_certificate_mode                        = var.function_app_flex_api.client_certificate_mode
  webdeploy_publish_basic_authentication_enabled = var.function_app_flex_api.webdeploy_publish_basic_authentication_enabled
  enable_public_access                           = var.function_app_flex_api.enable_public_access
  enable_private_endpoint                        = var.function_app_flex_api.enable_private_endpoint
  service_plan_id                                = module.app_service_plan_plan.id
  storage_container_endpoint                     = module.storage_account_storage.id
}
module "log_analytics_workspace_logs" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/log-analytics-workspace?ref=log-analytics-workspace/v1.0.0"

  resource_group_name       = var.log_analytics_workspace_logs.resource_group_name
  location                  = var.log_analytics_workspace_logs.location
  name                      = var.log_analytics_workspace_logs.name
  tags                      = var.log_analytics_workspace_logs.tags
  sku                       = var.log_analytics_workspace_logs.sku
  retention_in_days         = var.log_analytics_workspace_logs.retention_in_days
  daily_quota_gb            = var.log_analytics_workspace_logs.daily_quota_gb
  enable_internet_ingestion = var.log_analytics_workspace_logs.enable_internet_ingestion
  enable_internet_query     = var.log_analytics_workspace_logs.enable_internet_query
}
module "application_insights_insights" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/application-insights?ref=application-insights/v2.1.0"

  resource_group_name                   = var.application_insights_insights.resource_group_name
  location                              = var.application_insights_insights.location
  name                                  = var.application_insights_insights.name
  tags                                  = var.application_insights_insights.tags
  application_type                      = var.application_insights_insights.application_type
  retention_in_days                     = var.application_insights_insights.retention_in_days
  daily_data_cap_notifications_disabled = var.application_insights_insights.daily_data_cap_notifications_disabled
  sampling_percentage                   = var.application_insights_insights.sampling_percentage
  local_authentication_disabled         = var.application_insights_insights.local_authentication_disabled
  disable_ip_masking                    = var.application_insights_insights.disable_ip_masking
  internet_ingestion_enabled            = var.application_insights_insights.internet_ingestion_enabled
  internet_query_enabled                = var.application_insights_insights.internet_query_enabled
  force_customer_storage_for_profiler   = var.application_insights_insights.force_customer_storage_for_profiler
  workspace_id                          = module.log_analytics_workspace_logs.id
}

output "static_web_app_swa_id" {
  value = module.static_web_app_swa.id
}
output "static_web_app_swa_name" {
  value = module.static_web_app_swa.name
}
output "static_web_app_swa_default_host_name" {
  value = module.static_web_app_swa.default_host_name
}
output "static_web_app_swa_private_ip_address" {
  value = module.static_web_app_swa.private_ip_address
}
output "app_service_plan_plan_id" {
  value = module.app_service_plan_plan.id
}
output "app_service_plan_plan_name" {
  value = module.app_service_plan_plan.name
}
output "storage_account_storage_id" {
  value = module.storage_account_storage.id
}
output "storage_account_storage_primary_blob_endpoint" {
  value = module.storage_account_storage.primary_blob_endpoint
}
output "function_app_flex_api_id" {
  value = module.function_app_flex_api.id
}
output "function_app_flex_api_name" {
  value = module.function_app_flex_api.name
}
output "function_app_flex_api_default_hostname" {
  value = module.function_app_flex_api.default_hostname
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
