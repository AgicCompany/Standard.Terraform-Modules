data "azurerm_client_config" "current" {}

data "azurerm_monitor_diagnostic_categories" "this" {
  count       = var.diagnostic_settings == null ? 0 : 1
  resource_id = azurerm_postgresql_flexible_server.this.id
}
