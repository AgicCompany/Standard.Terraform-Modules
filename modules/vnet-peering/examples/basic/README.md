# VNet Peering - Basic Example

Deploys bidirectional VNet peering between a hub and spoke VNet.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.59.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vnet_peering"></a> [vnet\_peering](#module\_vnet\_peering) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_local_to_remote_peering_id"></a> [local\_to\_remote\_peering\_id](#output\_local\_to\_remote\_peering\_id) | n/a |
| <a name="output_remote_to_local_peering_id"></a> [remote\_to\_local\_peering\_id](#output\_remote\_to\_local\_peering\_id) | n/a |
<!-- END_TF_DOCS -->