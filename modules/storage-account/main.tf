resource "azurerm_storage_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  # Security settings
  min_tls_version                 = var.min_tls_version
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  public_network_access_enabled   = var.enable_public_access

  # Blob properties
  blob_properties {
    versioning_enabled = var.enable_versioning

    dynamic "delete_retention_policy" {
      for_each = var.enable_blob_soft_delete ? [1] : []

      content {
        days = var.blob_soft_delete_retention_days
      }
    }

    dynamic "container_delete_retention_policy" {
      for_each = var.enable_container_soft_delete ? [1] : []

      content {
        days = var.container_soft_delete_retention_days
      }
    }
  }

  # Network rules (only when public access is enabled)
  dynamic "network_rules" {
    for_each = var.enable_public_access && var.network_rules != null ? [var.network_rules] : []

    content {
      bypass                     = network_rules.value.bypass
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "this" {
  for_each = local.private_endpoints

  name                = "pe-${var.name}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}-${each.key}"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.dns_zone_id != null ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [each.value.dns_zone_id]
    }
  }

  tags = var.tags
}
