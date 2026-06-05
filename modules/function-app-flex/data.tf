# data.tf - Data sources

data "azurerm_monitor_diagnostic_categories" "this" {
  count       = var.diagnostic_settings == null ? 0 : 1
  resource_id = azurerm_function_app_flex_consumption.this.id
}
