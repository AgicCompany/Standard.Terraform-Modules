resource "azurerm_public_ip" "this" {
  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = var.sku

  copy_paste_enabled     = var.copy_paste_enabled
  file_copy_enabled      = var.sku == "Standard" ? var.file_copy_enabled : false
  ip_connect_enabled     = var.sku == "Standard" ? var.ip_connect_enabled : false
  shareable_link_enabled = var.sku == "Standard" ? var.shareable_link_enabled : false
  tunneling_enabled      = var.sku == "Standard" ? var.tunneling_enabled : false
  scale_units            = var.sku == "Standard" ? var.scale_units : null

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.this.id
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.sku == "Standard" || (!var.file_copy_enabled && !var.ip_connect_enabled && !var.shareable_link_enabled && !var.tunneling_enabled)
      error_message = "file_copy_enabled, ip_connect_enabled, shareable_link_enabled, and tunneling_enabled require Standard SKU."
    }
  }
}
