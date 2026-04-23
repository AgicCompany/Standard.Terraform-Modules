# Example: Complete Usage

Demonstrates multiple private DNS zones with hub-spoke virtual network linking topology.

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

- Resource group `rg-dns-complete-dev-weu-001`
- Hub virtual network `vnet-hub-dev-weu-001`
- Spoke virtual network `vnet-spoke-dev-weu-001`

**Private DNS Zones:**
- `privatelink.blob.core.windows.net` linked to both hub and spoke VNets
- `privatelink.vaultcore.azure.net` linked to both hub and spoke VNets

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
| <a name="module_dns_blob"></a> [dns\_blob](#module\_dns\_blob) | ../../ | n/a |
| <a name="module_dns_keyvault"></a> [dns\_keyvault](#module\_dns\_keyvault) | ../../ | n/a |

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
| <a name="output_blob_vnet_link_ids"></a> [blob\_vnet\_link\_ids](#output\_blob\_vnet\_link\_ids) | n/a |
| <a name="output_blob_zone_id"></a> [blob\_zone\_id](#output\_blob\_zone\_id) | n/a |
| <a name="output_keyvault_vnet_link_ids"></a> [keyvault\_vnet\_link\_ids](#output\_keyvault\_vnet\_link\_ids) | n/a |
| <a name="output_keyvault_zone_id"></a> [keyvault\_zone\_id](#output\_keyvault\_zone\_id) | n/a |
<!-- END_TF_DOCS -->