resource "azurerm_container_app_environment" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  log_analytics_workspace_id = var.log_analytics_workspace_id

  infrastructure_subnet_id = var.infrastructure_subnet_id
  # azurerm rejects these two whenever they are set without a subnet, even
  # when false -- only forward them once infrastructure_subnet_id is given.
  internal_load_balancer_enabled = var.infrastructure_subnet_id != null ? var.enable_internal_load_balancer : null
  zone_redundancy_enabled        = var.infrastructure_subnet_id != null ? var.enable_zone_redundancy : null

  dynamic "workload_profile" {
    for_each = var.workload_profiles

    content {
      name                  = workload_profile.key
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }

  tags = var.tags
}
