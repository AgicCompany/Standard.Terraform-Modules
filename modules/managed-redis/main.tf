resource "azurerm_managed_redis" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name

  high_availability_enabled = var.high_availability_enabled
  public_network_access     = var.enable_public_access ? "Enabled" : "Disabled"

  default_database {
    client_protocol                    = var.client_protocol
    clustering_policy                  = var.clustering_policy
    eviction_policy                    = var.eviction_policy
    geo_replication_group_name         = var.geo_replication_group_name
    access_keys_authentication_enabled = var.access_keys_authentication_enabled

    persistence_append_only_file_backup_frequency = var.persistence_aof_frequency
    persistence_redis_database_backup_frequency   = var.persistence_rdb_frequency

    dynamic "module" {
      for_each = var.modules

      content {
        name = module.value.name
        args = module.value.args
      }
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []

    content {
      key_vault_key_id          = customer_managed_key.value.key_vault_key_id
      user_assigned_identity_id = customer_managed_key.value.identity_id
    }
  }

  tags = var.tags

  lifecycle {
    # RediSearch requires EnterpriseCluster
    precondition {
      condition     = !contains([for m in var.modules : m.name], "RediSearch") || var.clustering_policy == "EnterpriseCluster"
      error_message = "RediSearch module requires clustering_policy = \"EnterpriseCluster\"."
    }

    # RediSearch requires NoEviction
    precondition {
      condition     = !contains([for m in var.modules : m.name], "RediSearch") || var.eviction_policy == "NoEviction"
      error_message = "RediSearch module requires eviction_policy = \"NoEviction\"."
    }

    # Geo-replication requires HA
    precondition {
      condition     = var.geo_replication_group_name == null || var.high_availability_enabled
      error_message = "Geo-replication requires high_availability_enabled = true."
    }

    # Geo-replication is incompatible with persistence
    precondition {
      condition     = var.geo_replication_group_name == null || (var.persistence_aof_frequency == null && var.persistence_rdb_frequency == null)
      error_message = "Geo-replication cannot be used with persistence (AOF or RDB). Set both persistence variables to null."
    }

    # Geo-replication only supports RediSearch and RedisJSON
    precondition {
      condition     = var.geo_replication_group_name == null || alltrue([for m in var.modules : contains(["RediSearch", "RedisJSON"], m.name)])
      error_message = "Geo-replication only supports RediSearch and RedisJSON modules. RedisBloom and RedisTimeSeries are not compatible."
    }

    # Geo-replication not supported on B0/B1
    precondition {
      condition     = var.geo_replication_group_name == null || !can(regex("^Balanced_B[01]$", var.sku_name))
      error_message = "Geo-replication is not supported on Balanced_B0 or Balanced_B1 SKUs."
    }

    # AOF and RDB are mutually exclusive
    precondition {
      condition     = var.persistence_aof_frequency == null || var.persistence_rdb_frequency == null
      error_message = "AOF and RDB persistence are mutually exclusive. Set one or the other, not both."
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
    private_connection_resource_id = azurerm_managed_redis.this.id
    subresource_names              = ["redisEnterprise"]
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
