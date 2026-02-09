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
  replicas_per_master           = var.replicas_per_master
  replicas_per_primary          = var.replicas_per_primary
  zones                         = length(var.zones) > 0 ? var.zones : null

  redis_configuration {
    maxmemory_policy                = var.redis_configuration.maxmemory_policy
    maxmemory_reserved              = var.redis_configuration.maxmemory_reserved
    maxfragmentationmemory_reserved = var.redis_configuration.maxfragmentationmemory_reserved
    notify_keyspace_events          = var.redis_configuration.notify_keyspace_events
    aof_backup_enabled              = var.redis_configuration.aof_backup_enabled
    rdb_backup_enabled              = var.redis_configuration.rdb_backup_enabled
    rdb_backup_frequency            = var.redis_configuration.rdb_backup_frequency
    rdb_backup_max_snapshot_count   = var.redis_configuration.rdb_backup_max_snapshot_count
    rdb_storage_connection_string   = var.redis_configuration.rdb_storage_connection_string
  }

  dynamic "patch_schedule" {
    for_each = var.patch_schedule != null ? [var.patch_schedule] : []

    content {
      day_of_week    = patch_schedule.value.day_of_week
      start_hour_utc = patch_schedule.value.start_hour_utc
    }
  }

  tags = var.tags
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

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}
