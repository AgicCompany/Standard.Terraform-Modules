# vnet-peering

**Complexity:** Low

Creates bidirectional Azure Virtual Network peering between two VNets. Both peering directions are managed as a single unit.

## Usage

```hcl
module "vnet_peering" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//vnet-peering?ref=vnet-peering/v1.0.0"

  name = "hub-to-spoke"

  virtual_network_id                  = azurerm_virtual_network.hub.id
  virtual_network_resource_group_name = azurerm_resource_group.example.name
  virtual_network_name                = azurerm_virtual_network.hub.name

  remote_virtual_network_id                  = azurerm_virtual_network.spoke.id
  remote_virtual_network_resource_group_name = azurerm_resource_group.example.name
  remote_virtual_network_name                = azurerm_virtual_network.spoke.name

  tags = {
    Environment = "dev"
  }
}
```

## Features

- Bidirectional VNet peering (creates both directions)
- Configurable traffic forwarding
- Gateway transit support
- Remote gateway usage support

## Security Defaults

- Virtual network access is allowed by default (required for peering to function)
- Forwarded traffic is denied by default
- Gateway transit is disabled by default

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **Bidirectional:** This module creates both peering directions. You do not need to call it twice.
- **Gateway transit:** `allow_gateway_transit` is set on the local (hub) side. `use_remote_gateways` is set on the remote (spoke) side. They are mutually exclusive per peering direction.
- **Cross-subscription peering:** Both VNets can be in different subscriptions if the provider has access to both. For cross-subscription scenarios, configure multiple azurerm providers.
- **No location:** VNet peering does not require a location -- it inherits from the VNets being peered.
- **No tags:** Azure VNet peering resources do not support tags. The `tags` variable is included for interface consistency but is not used.
