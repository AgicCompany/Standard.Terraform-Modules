# storage-account

**Complexity:** Medium

Creates an Azure Storage Account with secure defaults and optional private endpoints for blob, file, table, and queue subresources.

## Usage

```hcl
module "storage_account" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//storage-account?ref=storage-account/v1.0.0"

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

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **No access keys in outputs:** Access keys and connection strings are never exposed. Retrieve them via data source or Key Vault.
- **Storage account naming:** Names must be 3-24 characters, lowercase letters and numbers only. The module validates this constraint.
- **Blob-only by default:** Only the blob private endpoint is enabled by default to avoid creating unnecessary endpoints.
- **Soft delete:** Enabled by default with 7-day retention. Increase retention for production workloads.
