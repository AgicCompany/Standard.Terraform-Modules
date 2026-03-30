resource "azurerm_cosmosdb_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type
  kind                = var.kind

  free_tier_enabled          = var.free_tier_enabled
  automatic_failover_enabled = var.automatic_failover_enabled
  minimal_tls_version        = var.minimal_tls_version

  public_network_access_enabled     = var.enable_public_access
  is_virtual_network_filter_enabled = false
  multiple_write_locations_enabled  = var.enable_multiple_write_locations
  local_authentication_disabled     = !var.enable_local_auth

  ip_range_filter = var.ip_range_filter

  consistency_policy {
    consistency_level       = var.consistency_policy.consistency_level
    max_interval_in_seconds = var.consistency_policy.consistency_level == "BoundedStaleness" ? var.consistency_policy.max_interval_in_seconds : null
    max_staleness_prefix    = var.consistency_policy.consistency_level == "BoundedStaleness" ? var.consistency_policy.max_staleness_prefix : null
  }

  dynamic "geo_location" {
    for_each = var.geo_locations != null ? var.geo_locations : [{
      location          = var.location
      failover_priority = 0
      zone_redundant    = false
    }]

    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = geo_location.value.zone_redundant
    }
  }

  dynamic "backup" {
    for_each = [var.backup]

    content {
      type                = backup.value.type
      interval_in_minutes = backup.value.type == "Periodic" ? backup.value.interval_in_minutes : null
      retention_in_hours  = backup.value.type == "Periodic" ? backup.value.retention_in_hours : null
      storage_redundancy  = backup.value.type == "Periodic" ? backup.value.storage_redundancy : null
      tier                = backup.value.type == "Continuous" ? backup.value.tier : null
    }
  }

  dynamic "capacity" {
    for_each = var.capacity != null ? [var.capacity] : []

    content {
      total_throughput_limit = capacity.value.total_throughput_limit
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !var.enable_multiple_write_locations || !contains(["Strong", "BoundedStaleness"], var.consistency_policy.consistency_level)
      error_message = "Strong and BoundedStaleness consistency levels are incompatible with multiple write locations. Use Session, Eventual, or ConsistentPrefix."
    }
  }
}

resource "azurerm_cosmosdb_sql_database" "this" {
  for_each = var.sql_databases

  name                = each.key
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = each.value.max_throughput == null ? each.value.throughput : null

  dynamic "autoscale_settings" {
    for_each = each.value.max_throughput != null ? [each.value.max_throughput] : []

    content {
      max_throughput = autoscale_settings.value
    }
  }
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                          = coalesce(var.private_endpoint_name, "pep-${var.name}")
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_id
  custom_network_interface_name = coalesce(var.private_endpoint_nic_name, "pep-${var.name}-nic")

  private_service_connection {
    name                           = coalesce(var.private_service_connection_name, "psc-${var.name}")
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = var.tags
}
