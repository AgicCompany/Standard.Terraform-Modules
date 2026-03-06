# Module: storage-account

**Priority:** P0
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_storage_account` — Azure Storage Account
- `azurerm_private_endpoint` — Private endpoints for enabled subresources (blob, file, table, queue)
- `azurerm_private_dns_zone_group` — DNS zone groups for private endpoints

## v1.0.0 Scope

A storage account with secure defaults, optional private endpoints for all four primary subresources (blob, file, table, queue), and configurable blob/container settings. The module follows the "private by default" pattern — public access is disabled unless explicitly enabled.

### In Scope

- Storage account creation with secure defaults
- Private endpoints for blob, file, table, queue (configurable per subresource)
- Blob soft delete and container soft delete
- Blob versioning (optional)
- TLS 1.2 minimum
- HTTPS only
- Network rules for IP/VNet exceptions when public access is needed

### Out of Scope (Deferred)

- Container creation (use `azurerm_storage_container` directly)
- File share creation (use `azurerm_storage_share` directly)
- Queue/table creation
- Static website hosting
- CORS rules
- Lifecycle management policies
- Immutability policies
- Customer-managed keys
- Geo-replication (GRS/GZRS) — deferred to v1.1.0
- Azure Files authentication (AD/AAD DS)

## Feature Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_private_endpoints` | bool | `true` | Create private endpoints for enabled subresources |
| `enable_public_access` | bool | `false` | Allow public network access |
| `enable_blob_private_endpoint` | bool | `true` | Create private endpoint for blob subresource |
| `enable_file_private_endpoint` | bool | `false` | Create private endpoint for file subresource |
| `enable_table_private_endpoint` | bool | `false` | Create private endpoint for table subresource |
| `enable_queue_private_endpoint` | bool | `false` | Create private endpoint for queue subresource |
| `enable_versioning` | bool | `false` | Enable blob versioning |
| `enable_blob_soft_delete` | bool | `true` | Enable blob soft delete |
| `enable_container_soft_delete` | bool | `true` | Enable container soft delete |

## Private Endpoint Support

| Subresource | Private DNS Zone |
|-------------|------------------|
| `blob` | `privatelink.blob.core.windows.net` |
| `file` | `privatelink.file.core.windows.net` |
| `table` | `privatelink.table.core.windows.net` |
| `queue` | `privatelink.queue.core.windows.net` |

### Required Variables (when private endpoints enabled)

| Variable | Type | Description |
|----------|------|-------------|
| `subnet_id` | string | Subnet ID for the private endpoints |
| `private_dns_zone_ids` | map(string) | Map of subresource name to private DNS zone ID |

### Private DNS Zone IDs Example

```hcl
private_dns_zone_ids = {
  blob  = module.private_dns.zone_ids["privatelink.blob.core.windows.net"]
  file  = module.private_dns.zone_ids["privatelink.file.core.windows.net"]
  table = module.private_dns.zone_ids["privatelink.table.core.windows.net"]
  queue = module.private_dns.zone_ids["privatelink.queue.core.windows.net"]
}
```

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `account_tier` | string | No | `"Standard"` | Account tier (`Standard` or `Premium`) |
| `account_replication_type` | string | No | `"LRS"` | Replication type (`LRS`, `ZRS`, `GRS`, `RAGRS`, `GZRS`, `RAGZRS`) |
| `account_kind` | string | No | `"StorageV2"` | Account kind (`StorageV2`, `BlobStorage`, `BlockBlobStorage`, `FileStorage`) |
| `access_tier` | string | No | `"Hot"` | Access tier for BlobStorage/StorageV2 (`Hot` or `Cool`) |
| `min_tls_version` | string | No | `"TLS1_2"` | Minimum TLS version |
| `allow_nested_items_to_be_public` | bool | No | `false` | Allow blob public access (individual container level) |
| `shared_access_key_enabled` | bool | No | `true` | Enable shared key authorization |
| `blob_soft_delete_retention_days` | number | No | `7` | Blob soft delete retention (1-365 days) |
| `container_soft_delete_retention_days` | number | No | `7` | Container soft delete retention (1-365 days) |
| `network_rules` | object | No | `null` | Network rules for IP/VNet exceptions |

### Network Rules Variable Structure

```hcl
variable "network_rules" {
  type = object({
    bypass                     = optional(list(string), ["AzureServices"])
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default     = null
  description = "Network rules for the storage account. Only applies when enable_public_access = true."
}
```

### Example Usage

```hcl
# Private access only (default) - blob endpoint only
module "storage" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/storage-account?ref=storage-account/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "stpaymentsdevweu001"
  tags                = local.common_tags

  subnet_id = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_ids = {
    blob = module.private_dns.zone_ids["privatelink.blob.core.windows.net"]
  }
}

# With all four private endpoints
module "storage_full" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/storage-account?ref=storage-account/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "stpaymentsdevweu001"
  tags                = local.common_tags

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
}

# With public access and network rules (for legacy scenarios)
module "storage_public" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/storage-account?ref=storage-account/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "stpaymentsdevweu001"
  tags                = local.common_tags

  enable_private_endpoints = false
  enable_public_access     = true

  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
  }
}
```

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `primary_blob_endpoint` | Primary blob endpoint URL |
| `primary_file_endpoint` | Primary file endpoint URL |
| `primary_table_endpoint` | Primary table endpoint URL |
| `primary_queue_endpoint` | Primary queue endpoint URL |
| `primary_location` | Primary location of the storage account |
| `private_endpoint_ids` | Map of subresource name to private endpoint ID (when enabled) |
| `private_ip_addresses` | Map of subresource name to private IP address (when enabled) |
| `public_storage_account_id` | Storage account resource ID (for cross-project consumption) |
| `public_storage_account_name` | Storage account name (for cross-project consumption) |
| `public_primary_blob_endpoint` | Primary blob endpoint URL (for cross-project consumption) |

## Notes

- **No access keys in outputs:** Following the Module Standards, access keys and connection strings are never exposed as outputs. Consumers retrieve them via data source or Key Vault reference.
- **Blob-only by default:** Only the blob private endpoint is enabled by default. Enable file/table/queue endpoints explicitly when needed to avoid creating unnecessary private endpoints.
- **Storage account naming:** Storage account names must be globally unique, 3-24 characters, lowercase letters and numbers only. The CAF naming convention (`st<project><env><region><instance>`) is designed to fit these constraints.
- **Network rules vs private endpoints:** Network rules only apply when `enable_public_access = true`. When using private endpoints exclusively, network rules are not needed. The storage account's public endpoint is disabled.
- **Soft delete defaults:** Blob and container soft delete are enabled by default with 7-day retention. This protects against accidental deletion while keeping storage costs reasonable.
- **Shared key access:** Shared key authorization is enabled by default. For enhanced security, consider disabling it (`shared_access_key_enabled = false`) and using Azure AD authentication exclusively. However, some scenarios (Azure Functions, legacy apps) still require shared key access.
