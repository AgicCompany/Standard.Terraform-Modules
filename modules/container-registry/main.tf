resource "azurerm_container_registry" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  admin_enabled                 = var.enable_admin
  public_network_access_enabled = var.enable_public_access
  trust_policy_enabled          = var.enable_content_trust

  identity {
    type = "SystemAssigned"
  }

  dynamic "georeplications" {
    for_each = var.enable_geo_replication ? var.georeplications : {}

    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      tags                      = georeplications.value.tags
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !var.enable_geo_replication || var.sku == "Premium"
      error_message = "Geo-replication requires Premium SKU. Set sku = \"Premium\" or disable geo-replication."
    }

    precondition {
      condition     = !var.enable_content_trust || var.sku == "Premium"
      error_message = "Content trust requires Premium SKU. Set sku = \"Premium\" or disable content trust."
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
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
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
