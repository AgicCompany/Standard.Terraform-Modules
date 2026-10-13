resource "azurerm_storage_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = local.access_tier

  # Security settings
  min_tls_version                 = var.min_tls_version == "1.2" ? "TLS1_2" : var.min_tls_version
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  public_network_access_enabled   = var.enable_public_access

  # Blob properties (not supported for FileStorage account kind)
  dynamic "blob_properties" {
    for_each = var.account_kind != "FileStorage" ? [1] : []

    content {
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

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  # Inline block rather than azurerm_storage_account_customer_managed_key: the two
  # conflict, and the inline one sets the key in the same call that creates the
  # account. Both module inputs render into key_vault_key_id -- the provider parses
  # Key Vault and Managed HSM key IDs with the same function, and its own
  # managed_hsm_key_id attribute is deprecated and gone in azurerm 5.0.
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []

    content {
      key_vault_key_id = coalesce(
        customer_managed_key.value.key_vault_key_id,
        customer_managed_key.value.managed_hsm_key_id,
      )
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.network_rules == null || var.enable_public_access
      error_message = "network_rules are only applied when enable_public_access = true. Remove network_rules or set enable_public_access = true."
    }

    # CMK needs a user-assigned identity, and Azure uses exactly the identity named
    # here to reach the key -- so it has to be one the account actually carries.
    # Resource IDs vary in case across sources, hence the lower() comparison.
    precondition {
      condition = (
        var.customer_managed_key == null ? true
        : (
          var.identity == null ? false
          : (
            !strcontains(var.identity.type, "UserAssigned") ? false
            : contains(
              [for id in coalesce(var.identity.identity_ids, []) : lower(id)],
              lower(var.customer_managed_key.user_assigned_identity_id)
            )
          )
        )
      )
      error_message = "customer_managed_key.user_assigned_identity_id must be listed in identity.identity_ids, and identity.type must include \"UserAssigned\"."
    }

    # Azure only supports customer-managed keys on StorageV2 or Premium accounts.
    # The provider raises this at apply time; catch it at plan time instead.
    precondition {
      condition = (
        var.customer_managed_key == null ? true
        : (
          var.account_kind == "StorageV2" ? true
          : var.account_tier == "Premium"
        )
      )
      error_message = "customer_managed_key requires account_kind = \"StorageV2\" (the module default) or account_tier = \"Premium\"."
    }
  }
}

resource "azurerm_private_endpoint" "this" {
  for_each = local.private_endpoints

  name                = "${local.pe_name_prefix}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${local.psc_name_prefix}-${each.key}"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  custom_network_interface_name = "${local.pe_name_prefix}-${each.key}-nic"

  dynamic "private_dns_zone_group" {
    for_each = each.value.dns_zone_id != null ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [each.value.dns_zone_id]
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.subnet_id != null
      error_message = "subnet_id is required when private endpoints are enabled."
    }
  }
}


resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_storage_account.this.id

  log_analytics_workspace_id     = var.diagnostic_settings.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_settings.storage_account_id
  eventhub_authorization_rule_id = var.diagnostic_settings.eventhub_authorization_rule_id
  eventhub_name                  = var.diagnostic_settings.eventhub_name
  log_analytics_destination_type = var.diagnostic_settings.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = coalesce(
      var.diagnostic_settings.enabled_log_categories,
      try(data.azurerm_monitor_diagnostic_categories.this[0].log_category_types, [])
    )
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = coalesce(
      var.diagnostic_settings.enabled_metrics,
      try(data.azurerm_monitor_diagnostic_categories.this[0].metrics, [])
    )
    content {
      category = enabled_metric.value
    }
  }
}
