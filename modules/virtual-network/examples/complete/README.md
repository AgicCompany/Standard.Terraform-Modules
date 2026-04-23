# Example: Complete Usage

Demonstrates all features of the virtual-network module including NSG associations, route table associations, service endpoints, and subnet delegations.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated (`az login`)

## What This Creates

- Resource group `rg-vnet-complete-dev-weu-001`
- Virtual network `vnet-complete-dev-weu-001` with address space `10.0.0.0/16`
- Network security groups for app and data subnets
- Route table for data subnet
- Five subnets demonstrating different configurations:
  - `snet-app` - Application subnet with NSG and service endpoints
  - `snet-data` - Data subnet with NSG and route table association
  - `snet-private-endpoints` - Dedicated subnet for private endpoints
  - `snet-appservice` - Delegated subnet for App Service
  - `snet-container-apps` - Delegated subnet for Container Apps

## Clean Up

```bash
terraform destroy
```

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route_table.data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_space"></a> [address\_space](#output\_address\_space) | n/a |
| <a name="output_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#output\_subnet\_address\_prefixes) | n/a |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | n/a |
<!-- END_TF_DOCS -->