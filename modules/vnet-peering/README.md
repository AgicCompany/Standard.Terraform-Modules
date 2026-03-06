# vnet-peering

**Complexity:** Low

Creates bidirectional Azure Virtual Network peering between two VNets. Both peering directions are managed as a single unit.

## Usage

```hcl
module "vnet_peering" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//vnet-peering?ref=vnet-peering/v1.0.0"

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

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_peering_id` | Local-to-remote peering resource ID (for cross-project consumption) |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network_peering.local_to_remote](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.remote_to_local](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_forwarded_traffic"></a> [allow\_forwarded\_traffic](#input\_allow\_forwarded\_traffic) | Allow forwarded traffic from remote VNet | `bool` | `false` | no |
| <a name="input_allow_gateway_transit"></a> [allow\_gateway\_transit](#input\_allow\_gateway\_transit) | Allow gateway transit on the local VNet | `bool` | `false` | no |
| <a name="input_allow_virtual_network_access"></a> [allow\_virtual\_network\_access](#input\_allow\_virtual\_network\_access) | Allow access between peered VNets | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Peering name prefix. Creates two peerings: `{name}-local-to-remote` and `{name}-remote-to-local`. | `string` | n/a | yes |
| <a name="input_remote_virtual_network_id"></a> [remote\_virtual\_network\_id](#input\_remote\_virtual\_network\_id) | Resource ID of the remote virtual network | `string` | n/a | yes |
| <a name="input_remote_virtual_network_name"></a> [remote\_virtual\_network\_name](#input\_remote\_virtual\_network\_name) | Name of the remote virtual network | `string` | n/a | yes |
| <a name="input_remote_virtual_network_resource_group_name"></a> [remote\_virtual\_network\_resource\_group\_name](#input\_remote\_virtual\_network\_resource\_group\_name) | Resource group name of the remote virtual network | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. Included for interface consistency; VNet peering does not support tags. | `map(string)` | `{}` | no |
| <a name="input_use_remote_gateways"></a> [use\_remote\_gateways](#input\_use\_remote\_gateways) | Use remote VNet's gateway | `bool` | `false` | no |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | Resource ID of the local virtual network | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the local virtual network | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name) | Resource group name of the local virtual network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Local-to-remote peering resource ID |
| <a name="output_local_to_remote_id"></a> [local\_to\_remote\_id](#output\_local\_to\_remote\_id) | Local-to-remote peering resource ID |
| <a name="output_name"></a> [name](#output\_name) | Local-to-remote peering name |
| <a name="output_public_peering_id"></a> [public\_peering\_id](#output\_public\_peering\_id) | Local-to-remote peering resource ID (for cross-project consumption) |
| <a name="output_remote_to_local_id"></a> [remote\_to\_local\_id](#output\_remote\_to\_local\_id) | Remote-to-local peering resource ID |
<!-- END_TF_DOCS -->

## Notes

- **Bidirectional:** This module creates both peering directions. You do not need to call it twice.
- **Gateway transit:** `allow_gateway_transit` is set on the local (hub) side. `use_remote_gateways` is set on the remote (spoke) side. They are mutually exclusive per peering direction.
- **Cross-subscription peering:** Both VNets can be in different subscriptions if the provider has access to both. For cross-subscription scenarios, configure multiple azurerm providers.
- **No location:** VNet peering does not require a location -- it inherits from the VNets being peered.
- **No tags:** Azure VNet peering resources do not support tags. The `tags` variable is included for interface consistency but is not used.
