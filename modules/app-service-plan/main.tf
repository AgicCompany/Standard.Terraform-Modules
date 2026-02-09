resource "azurerm_service_plan" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name

  worker_count             = var.worker_count
  zone_balancing_enabled   = var.enable_zone_redundancy
  per_site_scaling_enabled = var.enable_per_site_scaling

  tags = var.tags
}
