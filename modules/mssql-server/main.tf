resource "azurerm_mssql_server" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  version             = var.version_number

  administrator_login          = var.enable_aad_only_auth ? null : var.administrator_login
  administrator_login_password = var.enable_aad_only_auth ? null : var.administrator_login_password

  minimum_tls_version                  = var.min_tls_version
  public_network_access_enabled        = var.enable_public_access
  outbound_network_restriction_enabled = var.enable_outbound_networking_restriction
  connection_policy                    = var.connection_policy

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username              = var.azuread_administrator.login_username
    object_id                   = var.azuread_administrator.object_id
    azuread_authentication_only = var.enable_aad_only_auth
  }

  lifecycle {
    precondition {
      condition     = var.enable_aad_only_auth || (var.administrator_login != null && var.administrator_login_password != null)
      error_message = "administrator_login and administrator_login_password are required when enable_aad_only_auth is false."
    }
  }

  tags = var.tags
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
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlServer"]
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
  resource_id = azurerm_mssql_server.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_mssql_server.this.id

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
