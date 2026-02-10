resource "azurerm_static_web_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_tier = var.sku_tier
  sku_size = var.sku_size

  configuration_file_changes_enabled = var.configuration_file_changes_enabled
  preview_environments_enabled       = var.preview_environments_enabled

  app_settings = var.app_settings

  tags = var.tags
}
