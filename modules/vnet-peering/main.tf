resource "azurerm_virtual_network_peering" "local_to_remote" {
  name                      = "${var.name}-local-to-remote"
  resource_group_name       = var.virtual_network_resource_group_name
  virtual_network_name      = var.virtual_network_name
  remote_virtual_network_id = var.remote_virtual_network_id

  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = var.local_use_remote_gateways

  lifecycle {
    precondition {
      condition     = var.allow_gateway_transit ? !var.local_use_remote_gateways : true
      error_message = "allow_gateway_transit and local_use_remote_gateways cannot both be true on the local-to-remote peering."
    }
  }
}

resource "azurerm_virtual_network_peering" "remote_to_local" {
  count = var.enable_remote_to_local ? 1 : 0

  name                      = "${var.name}-remote-to-local"
  resource_group_name       = var.remote_virtual_network_resource_group_name
  virtual_network_name      = var.remote_virtual_network_name
  remote_virtual_network_id = var.virtual_network_id

  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.remote_allow_gateway_transit
  use_remote_gateways          = var.use_remote_gateways

  lifecycle {
    precondition {
      condition = (
        var.remote_virtual_network_resource_group_name == null ? false
        : var.remote_virtual_network_name != null
      )
      error_message = "remote_virtual_network_resource_group_name and remote_virtual_network_name are required when enable_remote_to_local = true."
    }

    precondition {
      condition     = var.remote_allow_gateway_transit ? !var.use_remote_gateways : true
      error_message = "remote_allow_gateway_transit and use_remote_gateways cannot both be true on the remote-to-local peering."
    }
  }
}
