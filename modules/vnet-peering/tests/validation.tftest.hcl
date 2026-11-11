# Offline validation and precondition tests for vnet-peering.
mock_provider "azurerm" {}

variables {
  name                                = "peer-spoke-hub"
  virtual_network_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-spoke/providers/Microsoft.Network/virtualNetworks/vnet-spoke"
  virtual_network_resource_group_name = "rg-spoke"
  virtual_network_name                = "vnet-spoke"
  remote_virtual_network_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
}

run "accepts_bidirectional_peering" {
  command = plan
  variables {
    remote_virtual_network_resource_group_name = "rg-hub"
    remote_virtual_network_name                = "vnet-hub"
  }
}

run "accepts_one_sided_peering_without_remote_rg_or_name" {
  command = plan
  variables {
    enable_remote_to_local    = false
    local_use_remote_gateways = true
  }
  assert {
    condition     = output.remote_to_local_id == null
    error_message = "Expected remote_to_local_id to be null when enable_remote_to_local = false."
  }
}

run "rejects_bidirectional_peering_without_remote_rg" {
  command = plan
  variables {
    enable_remote_to_local      = true
    remote_virtual_network_name = "vnet-hub"
  }
  expect_failures = [azurerm_virtual_network_peering.remote_to_local]
}

run "rejects_conflicting_gateway_flags_on_local_to_remote" {
  command = plan
  variables {
    enable_remote_to_local    = false
    allow_gateway_transit     = true
    local_use_remote_gateways = true
  }
  expect_failures = [azurerm_virtual_network_peering.local_to_remote]
}
