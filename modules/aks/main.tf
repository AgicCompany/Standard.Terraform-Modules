resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = local.dns_prefix
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  private_cluster_enabled   = length(var.authorized_ip_ranges) == 0
  local_account_disabled    = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = var.workload_identity_enabled
  automatic_upgrade_channel = var.automatic_upgrade_channel != "none" ? var.automatic_upgrade_channel : null
  node_resource_group       = var.node_resource_group_name

  default_node_pool {
    name                        = "system"
    vm_size                     = var.default_node_pool.vm_size
    vnet_subnet_id              = var.default_node_pool.vnet_subnet_id
    auto_scaling_enabled        = var.enable_auto_scaling
    node_count                  = var.enable_auto_scaling ? null : var.default_node_pool.node_count
    min_count                   = var.enable_auto_scaling ? var.default_node_pool.min_count : null
    max_count                   = var.enable_auto_scaling ? var.default_node_pool.max_count : null
    os_disk_size_gb             = var.default_node_pool.os_disk_size_gb
    os_disk_type                = var.default_node_pool.os_disk_type
    os_sku                      = var.default_node_pool.os_sku
    zones                       = var.default_node_pool.zones
    max_pods                    = var.default_node_pool.max_pods
    temporary_name_for_rotation = var.default_node_pool.temporary_name_for_rotation

    upgrade_settings {
      max_surge                     = var.default_node_pool.upgrade_settings.max_surge
      drain_timeout_in_minutes      = var.default_node_pool.upgrade_settings.drain_timeout_in_minutes
      node_soak_duration_in_minutes = var.default_node_pool.upgrade_settings.node_soak_duration_in_minutes
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = var.network_profile.network_plugin
    network_plugin_mode = var.network_profile.network_plugin_mode
    network_policy      = var.network_profile.network_policy
    pod_cidr            = var.network_profile.network_plugin_mode == "overlay" ? var.network_profile.pod_cidr : null
    service_cidr        = var.network_profile.service_cidr
    dns_service_ip      = var.network_profile.dns_service_ip
    outbound_type       = var.network_profile.outbound_type
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = var.rbac_mode == "azure"
    admin_group_object_ids = var.admin_group_object_ids
  }

  dynamic "api_server_access_profile" {
    for_each = length(var.authorized_ip_ranges) > 0 ? [1] : []
    content {
      authorized_ip_ranges = var.authorized_ip_ranges
    }
  }

  dynamic "oms_agent" {
    for_each = var.enable_container_insights ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider != null ? [var.key_vault_secrets_provider] : []
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }

  tags = var.tags
}
