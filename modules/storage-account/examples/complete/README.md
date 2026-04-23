# Example: Complete Usage

Demonstrates all features of the storage-account module including all four private endpoints, versioning, soft delete, and public access with network rules.

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

- Resource group `rg-st-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zones for blob, file, table, and queue

**Storage account with all private endpoints (`stcompletedevweu001`):**
- Standard tier, ZRS replication
- TLS 1.2 minimum, HTTPS only
- Blob versioning enabled
- Blob and container soft delete (30 days)
- Private endpoints for blob, file, table, and queue

**Storage account with public access (`stpublicdevweu001`):**
- Standard tier, LRS replication
- Public network access enabled
- Network rules with IP restrictions

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
| <a name="module_storage_full"></a> [storage\_full](#module\_storage\_full) | ../../ | n/a |
| <a name="module_storage_public"></a> [storage\_public](#module\_storage\_public) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_full_primary_blob_endpoint"></a> [full\_primary\_blob\_endpoint](#output\_full\_primary\_blob\_endpoint) | n/a |
| <a name="output_full_private_endpoint_ids"></a> [full\_private\_endpoint\_ids](#output\_full\_private\_endpoint\_ids) | n/a |
| <a name="output_full_private_ip_addresses"></a> [full\_private\_ip\_addresses](#output\_full\_private\_ip\_addresses) | n/a |
| <a name="output_full_storage_account_id"></a> [full\_storage\_account\_id](#output\_full\_storage\_account\_id) | n/a |
| <a name="output_public_storage_account_id"></a> [public\_storage\_account\_id](#output\_public\_storage\_account\_id) | n/a |
<!-- END_TF_DOCS -->