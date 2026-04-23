resource "azurerm_eventhub_namespace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku      = var.sku
  capacity = var.capacity

  minimum_tls_version      = var.min_tls_version
  auto_inflate_enabled     = var.auto_inflate_enabled
  maximum_throughput_units = var.auto_inflate_enabled ? var.maximum_throughput_units : null

  public_network_access_enabled = var.enable_public_access
  local_authentication_enabled  = var.enable_local_auth

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !var.auto_inflate_enabled || var.sku != "Basic"
      error_message = "Auto-inflate is only supported on Standard and Premium SKUs."
    }

    precondition {
      condition     = !var.auto_inflate_enabled || var.maximum_throughput_units != null
      error_message = "maximum_throughput_units is required when auto_inflate_enabled is true."
    }
  }
}

resource "azurerm_eventhub" "this" {
  for_each = var.event_hubs

  name         = each.key
  namespace_id = azurerm_eventhub_namespace.this.id

  partition_count   = each.value.partition_count
  message_retention = each.value.message_retention

  lifecycle {
    precondition {
      condition     = var.sku != "Basic" || each.value.message_retention == 1
      error_message = "Event Hub '${each.key}': message_retention must be 1 for Basic SKU."
    }

    precondition {
      condition     = var.sku != "Standard" || each.value.message_retention <= 7
      error_message = "Event Hub '${each.key}': message_retention must be 1-7 for Standard SKU."
    }
  }
}

resource "azurerm_eventhub_consumer_group" "this" {
  for_each = local.consumer_groups

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this[each.value.eventhub_key].name
  resource_group_name = var.resource_group_name

  user_metadata = each.value.user_metadata
}

resource "azurerm_eventhub_namespace_authorization_rule" "this" {
  for_each = var.authorization_rules

  name                = each.key
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = var.resource_group_name

  listen = each.value.listen
  send   = each.value.send
  manage = each.value.manage
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
    private_connection_resource_id = azurerm_eventhub_namespace.this.id
    subresource_names              = ["namespace"]
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

data "azurerm_monitor_diagnostic_categories" "this" {
  count       = var.diagnostic_settings == null ? 0 : 1
  resource_id = azurerm_eventhub_namespace.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_eventhub_namespace.this.id

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
