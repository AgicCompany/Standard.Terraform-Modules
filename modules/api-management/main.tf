resource "azurerm_api_management" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  publisher_name  = var.publisher_name
  publisher_email = var.publisher_email

  sku_name = var.sku_name

  security {
    backend_ssl30_enabled  = false
    backend_tls10_enabled  = false
    backend_tls11_enabled  = false
    frontend_ssl30_enabled = false
    frontend_tls10_enabled = false
    frontend_tls11_enabled = false
  }

  virtual_network_type          = var.virtual_network_type
  public_network_access_enabled = var.enable_public_access
  client_certificate_enabled    = var.client_certificate_enabled
  gateway_disabled              = var.gateway_disabled
  min_api_version               = var.min_api_version
  notification_sender_email     = var.notification_sender_email
  zones                         = var.zones

  dynamic "virtual_network_configuration" {
    for_each = var.virtual_network_type != "None" && var.virtual_network_subnet_id != null ? [1] : []

    content {
      subnet_id = var.virtual_network_subnet_id
    }
  }

  dynamic "identity" {
    for_each = var.identity_type != "None" ? [1] : []

    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  dynamic "additional_location" {
    for_each = var.additional_locations

    content {
      location = additional_location.value.location
      zones    = additional_location.value.zones

      dynamic "virtual_network_configuration" {
        for_each = additional_location.value.virtual_network_subnet_id != null ? [1] : []

        content {
          subnet_id = additional_location.value.virtual_network_subnet_id
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.virtual_network_type == "None" || var.virtual_network_subnet_id != null
      error_message = "virtual_network_subnet_id is required when virtual_network_type is \"External\" or \"Internal\"."
    }

    precondition {
      condition     = !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) || length(var.identity_ids) > 0
      error_message = "identity_ids must contain at least one identity when identity_type is \"UserAssigned\" or \"SystemAssigned, UserAssigned\"."
    }

    precondition {
      condition     = var.virtual_network_type == "None" || can(regex("^Premium_", var.sku_name))
      error_message = "VNet integration (External or Internal) requires a Premium SKU. Set sku_name to a Premium tier or set virtual_network_type to None."
    }

    precondition {
      condition     = var.virtual_network_type == "None" || !var.enable_private_endpoint
      error_message = "VNet integration and private endpoint are mutually exclusive. Use virtual_network_type for classic VNet injection OR enable_private_endpoint for Private Link, not both."
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
    private_connection_resource_id = azurerm_api_management.this.id
    subresource_names              = ["Gateway"]
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
  resource_id = azurerm_api_management.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_api_management.this.id

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
