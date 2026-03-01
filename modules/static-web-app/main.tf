resource "azurerm_static_web_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_tier = var.sku_tier
  sku_size = var.sku_size

  configuration_file_changes_enabled = var.configuration_file_changes_enabled
  preview_environments_enabled       = var.preview_environments_enabled
  public_network_access_enabled      = var.enable_public_access

  app_settings = var.app_settings

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !var.enable_private_endpoint || var.sku_tier == "Standard"
      error_message = "Private endpoints require Standard SKU. Set sku_tier = \"Standard\" or disable PE."
    }

    precondition {
      condition     = var.enable_public_access || var.sku_tier == "Standard"
      error_message = "Disabling public network access requires Standard SKU. Set sku_tier = \"Standard\" or set enable_public_access = true."
    }
  }
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_static_web_app.this.id
    subresource_names              = ["staticSites"]
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
