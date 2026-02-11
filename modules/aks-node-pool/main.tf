resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  name                  = each.key
  kubernetes_cluster_id = var.kubernetes_cluster_id
  vm_size               = each.value.vm_size
  mode                  = each.value.mode
  os_type               = each.value.os_type
  os_sku                = each.value.os_type == "Windows" ? null : each.value.os_sku
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  vnet_subnet_id        = each.value.vnet_subnet_id
  zones                 = each.value.zones
  max_pods              = each.value.max_pods
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
  scale_down_mode       = each.value.scale_down_mode
  orchestrator_version  = each.value.orchestrator_version
  ultra_ssd_enabled     = each.value.ultra_ssd_enabled
  fips_enabled          = each.value.fips_enabled

  host_encryption_enabled     = each.value.host_encryption_enabled
  temporary_name_for_rotation = each.value.temporary_name_for_rotation

  # Autoscaling: node_count when disabled, min/max when enabled
  auto_scaling_enabled = each.value.auto_scaling_enabled
  node_count           = each.value.auto_scaling_enabled ? null : each.value.node_count
  min_count            = each.value.auto_scaling_enabled ? each.value.min_count : null
  max_count            = each.value.auto_scaling_enabled ? each.value.max_count : null

  # Spot: eviction fields only when priority is Spot
  priority        = each.value.priority
  eviction_policy = each.value.priority == "Spot" ? each.value.eviction_policy : null
  spot_max_price  = each.value.priority == "Spot" ? each.value.spot_max_price : null

  upgrade_settings {
    max_surge                     = each.value.upgrade_settings.max_surge
    drain_timeout_in_minutes      = each.value.upgrade_settings.drain_timeout_in_minutes
    node_soak_duration_in_minutes = each.value.upgrade_settings.node_soak_duration_in_minutes
  }

  tags = each.value.tags
}
