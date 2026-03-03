resource "azurerm_redis_cache" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku_name                      = var.sku_name
  family                        = var.family
  capacity                      = var.capacity
  minimum_tls_version           = var.minimum_tls_version
  non_ssl_port_enabled          = var.enable_non_ssl_port
  public_network_access_enabled = var.enable_public_access
  redis_version                 = var.redis_version
  replicas_per_master           = var.sku_name == "Premium" ? var.replicas_per_master : null
  replicas_per_primary          = var.sku_name == "Premium" ? var.replicas_per_primary : null
  zones                         = var.sku_name == "Premium" && length(var.zones) > 0 ? var.zones : null

  redis_configuration {
    maxmemory_policy                = var.redis_configuration.maxmemory_policy
    maxmemory_reserved              = var.redis_configuration.maxmemory_reserved
    maxfragmentationmemory_reserved = var.redis_configuration.maxfragmentationmemory_reserved
    notify_keyspace_events          = var.redis_configuration.notify_keyspace_events
    aof_backup_enabled              = var.sku_name == "Premium" ? var.redis_configuration.aof_backup_enabled : null
    rdb_backup_enabled              = var.sku_name == "Premium" ? var.redis_configuration.rdb_backup_enabled : null
    rdb_backup_frequency            = var.sku_name == "Premium" ? var.redis_configuration.rdb_backup_frequency : null
    rdb_backup_max_snapshot_count   = var.sku_name == "Premium" ? var.redis_configuration.rdb_backup_max_snapshot_count : null
    rdb_storage_connection_string   = var.sku_name == "Premium" ? var.redis_configuration.rdb_storage_connection_string : null
  }

  dynamic "patch_schedule" {
    for_each = var.sku_name == "Premium" && var.patch_schedule != null ? [var.patch_schedule] : []

    content {
      day_of_week    = patch_schedule.value.day_of_week
      start_hour_utc = patch_schedule.value.start_hour_utc
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition = (
        (contains(["Basic", "Standard"], var.sku_name) && var.family == "C") ||
        (var.sku_name == "Premium" && var.family == "P")
      )
      error_message = "Basic/Standard SKUs require family \"C\". Premium SKU requires family \"P\"."
    }

    precondition {
      condition     = !var.enable_private_endpoint || var.sku_name != "Basic"
      error_message = "Private endpoints require Standard or Premium SKU. Set sku_name to \"Standard\" or \"Premium\", or disable the private endpoint."
    }
  }
}

resource "azurerm_redis_firewall_rule" "this" {
  for_each = var.firewall_rules

  name                = each.key
  redis_cache_name    = azurerm_redis_cache.this.name
  resource_group_name = var.resource_group_name
  start_ip            = each.value.start_ip
  end_ip              = each.value.end_ip
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names              = ["redisCache"]
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
