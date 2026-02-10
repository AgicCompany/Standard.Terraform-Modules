resource "azurerm_virtual_network_peering" "local_to_remote" {
  name                      = "${var.name}-local-to-remote"
  resource_group_name       = var.virtual_network_resource_group_name
  virtual_network_name      = var.virtual_network_name
  remote_virtual_network_id = var.remote_virtual_network_id

  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "remote_to_local" {
  name                      = "${var.name}-remote-to-local"
  resource_group_name       = var.remote_virtual_network_resource_group_name
  virtual_network_name      = var.remote_virtual_network_name
  remote_virtual_network_id = var.virtual_network_id

  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_remote_gateways
}
