resource "azurerm_public_ip" "this" {
  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
  zones             = var.zones

  tags = var.tags
}

resource "azurerm_nat_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name                = var.sku_name
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  zones                   = var.zones

  tags = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.this.id
}
