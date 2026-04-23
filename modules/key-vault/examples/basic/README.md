# Example: Basic Usage

Demonstrates basic Key Vault creation with a private endpoint (the default configuration).

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

- Resource group `rg-kv-example-dev-weu-001`
- Virtual network `vnet-example-dev-weu-001` with private endpoint subnet
- Private DNS zone `privatelink.vaultcore.azure.net` linked to the VNet
- Key Vault `kv-example-dev-weu-001` with:
  - RBAC authorization enabled
  - Soft delete (90 days retention)
  - Purge protection enabled
  - Private endpoint

## Clean Up

```bash
terraform destroy
```

**Note:** Due to purge protection, the Key Vault will remain in a soft-deleted state for 90 days after destruction. To immediately purge it (if needed), use the Azure CLI:

```bash
az keyvault purge --name kv-example-dev-weu-001 --location westeurope
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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.69.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | n/a |
| <a name="output_vault_uri"></a> [vault\_uri](#output\_vault\_uri) | n/a |
<!-- END_TF_DOCS -->