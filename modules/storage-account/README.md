# storage-account

**Complexity:** Medium

Creates an Azure Storage Account with secure defaults and optional private endpoints for blob, file, table, and queue subresources.

## Usage

```hcl
module "storage_account" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/storage-account?ref=storage-account/v2.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "stpaymentsdevweu001"

  # Private endpoint for blob (default configuration)
  subnet_id = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_ids = {
    blob = module.private_dns.zone_ids["privatelink.blob.core.windows.net"]
  }

  tags = local.common_tags
}
```

## Features

- Secure defaults (TLS 1.2, HTTPS only, public access disabled)
- Private endpoints for blob, file, table, queue (configurable per subresource)
- Blob soft delete with configurable retention
- Container soft delete with configurable retention
- Blob versioning (optional)
- Network rules for public access scenarios

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| TLS version | 1.2 | `min_tls_version` |
| HTTPS only | Enabled | (not configurable) |
| Public network access | Disabled | `enable_public_access` |
| Blob public access | Disabled | `allow_nested_items_to_be_public` |
| Blob soft delete | Enabled (7 days) | `enable_blob_soft_delete`, `blob_soft_delete_retention_days` |
| Container soft delete | Enabled (7 days) | `enable_container_soft_delete`, `container_soft_delete_retention_days` |

## Private Endpoints

The module supports private endpoints for all four storage subresources:

| Subresource | Enable Variable | DNS Zone |
|-------------|-----------------|----------|
| blob | `enable_blob_private_endpoint` (default: true) | `privatelink.blob.core.windows.net` |
| file | `enable_file_private_endpoint` (default: false) | `privatelink.file.core.windows.net` |
| table | `enable_table_private_endpoint` (default: false) | `privatelink.table.core.windows.net` |
| queue | `enable_queue_private_endpoint` (default: false) | `privatelink.queue.core.windows.net` |

When any private endpoint is enabled, provide:

| Variable | Description |
|----------|-------------|
| `subnet_id` | Subnet ID for the private endpoints |
| `private_dns_zone_ids` | Map of subresource name to DNS zone ID |

Example with all endpoints:

```hcl
enable_blob_private_endpoint  = true
enable_file_private_endpoint  = true
enable_table_private_endpoint = true
enable_queue_private_endpoint = true

subnet_id = module.vnet.subnet_ids["snet-private-endpoints"]
private_dns_zone_ids = {
  blob  = module.private_dns.zone_ids["privatelink.blob.core.windows.net"]
  file  = module.private_dns.zone_ids["privatelink.file.core.windows.net"]
  table = module.private_dns.zone_ids["privatelink.table.core.windows.net"]
  queue = module.private_dns.zone_ids["privatelink.queue.core.windows.net"]
}
```

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_storage_account_id` | Storage account resource ID |
| `public_storage_account_name` | Storage account name |
| `public_primary_blob_endpoint` | Primary blob endpoint URL |

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
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Access tier for BlobStorage/StorageV2 (Hot, Cool, or Cold) | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Account kind (StorageV2, BlobStorage, BlockBlobStorage, FileStorage) | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Replication type (LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS) | `string` | `"LRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Account tier (Standard or Premium) | `string` | `"Standard"` | no |
| <a name="input_allow_nested_items_to_be_public"></a> [allow\_nested\_items\_to\_be\_public](#input\_allow\_nested\_items\_to\_be\_public) | Allow blob public access at the container level | `bool` | `false` | no |
| <a name="input_blob_soft_delete_retention_days"></a> [blob\_soft\_delete\_retention\_days](#input\_blob\_soft\_delete\_retention\_days) | Blob soft delete retention period in days (1-365) | `number` | `7` | no |
| <a name="input_container_soft_delete_retention_days"></a> [container\_soft\_delete\_retention\_days](#input\_container\_soft\_delete\_retention\_days) | Container soft delete retention period in days (1-365) | `number` | `7` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Optional diagnostic settings. null disables. Supports multi-sink (Log Analytics, storage account, Event Hub). enabled\_log\_categories = null -> all categories the resource supports. enabled\_metrics = null -> all metrics the resource supports. At least one of log\_analytics\_workspace\_id, storage\_account\_id, or eventhub\_authorization\_rule\_id is required when the object is non-null. | <pre>object({<br/>    name                           = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    enabled_log_categories         = optional(list(string))<br/>    enabled_metrics                = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_enable_blob_private_endpoint"></a> [enable\_blob\_private\_endpoint](#input\_enable\_blob\_private\_endpoint) | Create private endpoint for blob subresource | `bool` | `true` | no |
| <a name="input_enable_blob_soft_delete"></a> [enable\_blob\_soft\_delete](#input\_enable\_blob\_soft\_delete) | Enable blob soft delete | `bool` | `true` | no |
| <a name="input_enable_container_soft_delete"></a> [enable\_container\_soft\_delete](#input\_enable\_container\_soft\_delete) | Enable container soft delete | `bool` | `true` | no |
| <a name="input_enable_file_private_endpoint"></a> [enable\_file\_private\_endpoint](#input\_enable\_file\_private\_endpoint) | Create private endpoint for file subresource | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create private endpoints for enabled subresources (blob, file, queue, table). | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access to the storage account | `bool` | `false` | no |
| <a name="input_enable_queue_private_endpoint"></a> [enable\_queue\_private\_endpoint](#input\_enable\_queue\_private\_endpoint) | Create private endpoint for queue subresource | `bool` | `false` | no |
| <a name="input_enable_table_private_endpoint"></a> [enable\_table\_private\_endpoint](#input\_enable\_table\_private\_endpoint) | Create private endpoint for table subresource | `bool` | `false` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable blob versioning | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | Minimum TLS version. Only "1.2" is supported; TLS 1.0/1.1 retired by Azure. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Storage account name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | Network rules for the storage account. Only applies when enable\_public\_access = true. | <pre>object({<br/>    bypass                     = optional(list(string), ["AzureServices"])<br/>    default_action             = optional(string, "Deny")<br/>    ip_rules                   = optional(list(string), [])<br/>    virtual_network_subnet_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Map of subresource name (blob, file, table, queue) to private DNS zone ID. | `map(string)` | `{}` | no |
| <a name="input_private_endpoint_name_prefix"></a> [private\_endpoint\_name\_prefix](#input\_private\_endpoint\_name\_prefix) | Prefix for private endpoint and NIC resource names. Suffixed with subresource (e.g., "pep-storage" -> "pep-storage-blob", "pep-storage-blob-nic"). null defaults to "pep-<var.name>". Does NOT affect the private\_service\_connection name, which always uses "psc-<var.name>-<subresource>". | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#input\_shared\_access\_key\_enabled) | Enable shared key authorization. Disabled by default; use managed identity where possible. | `bool` | `false` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for private endpoints. Required when any private endpoint is enabled. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Storage account resource ID |
| <a name="output_name"></a> [name](#output\_name) | Storage account name |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | Primary blob endpoint URL |
| <a name="output_primary_file_endpoint"></a> [primary\_file\_endpoint](#output\_primary\_file\_endpoint) | Primary file endpoint URL |
| <a name="output_primary_location"></a> [primary\_location](#output\_primary\_location) | Primary location of the storage account |
| <a name="output_primary_queue_endpoint"></a> [primary\_queue\_endpoint](#output\_primary\_queue\_endpoint) | Primary queue endpoint URL |
| <a name="output_primary_table_endpoint"></a> [primary\_table\_endpoint](#output\_primary\_table\_endpoint) | Primary table endpoint URL |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of subresource name to private endpoint ID |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | Map of subresource name to private IP address |
| <a name="output_public_primary_blob_endpoint"></a> [public\_primary\_blob\_endpoint](#output\_public\_primary\_blob\_endpoint) | Primary blob endpoint URL (for cross-project consumption) |
| <a name="output_public_storage_account_id"></a> [public\_storage\_account\_id](#output\_public\_storage\_account\_id) | Storage account resource ID (for cross-project consumption) |
| <a name="output_public_storage_account_name"></a> [public\_storage\_account\_name](#output\_public\_storage\_account\_name) | Storage account name (for cross-project consumption) |
<!-- END_TF_DOCS -->

## Notes

- **No access keys in outputs:** Access keys and connection strings are never exposed. Retrieve them via data source or Key Vault.
- **Storage account naming:** Names must be 3-24 characters, lowercase letters and numbers only. The module validates this constraint.
- **Blob-only by default:** Only the blob private endpoint is enabled by default to avoid creating unnecessary endpoints.
- **Soft delete:** Enabled by default with 7-day retention. Increase retention for production workloads.
