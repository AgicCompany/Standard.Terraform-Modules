# data.tf - Data sources

data "azurerm_monitor_diagnostic_categories" "this" {
  count       = var.diagnostic_settings == null ? 0 : 1
  resource_id = azurerm_mssql_database.this.id
}
