resource "azurerm_mssql_database" "this" {
  name      = var.name
  server_id = var.server_id

  sku_name     = var.sku_name
  max_size_gb  = var.max_size_gb
  collation    = var.collation
  license_type = var.license_type

  zone_redundant     = var.enable_zone_redundancy
  geo_backup_enabled = var.enable_geo_redundant_backup
  read_scale         = var.enable_read_scale

  short_term_retention_policy {
    retention_days = var.short_term_retention_days
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !can(regex("^HS_", var.sku_name)) || !var.enable_geo_redundant_backup
      error_message = "geo_backup_enabled is not supported for Hyperscale (HS_*) SKUs. Set enable_geo_redundant_backup = false."
    }
  }
}

data "azurerm_monitor_diagnostic_categories" "this" {
  count       = var.diagnostic_settings == null ? 0 : 1
  resource_id = azurerm_mssql_database.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_mssql_database.this.id

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
