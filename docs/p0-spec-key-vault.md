# Module: key-vault

**Priority:** P0
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_key_vault` — Azure Key Vault
- `azurerm_private_endpoint` — Private endpoint for the vault (when enabled)
- `azurerm_private_dns_zone_group` — DNS zone group for private endpoint (when enabled)

## v1.0.0 Scope

A Key Vault with RBAC-based authorization (not access policies), secure defaults, and optional private endpoint. The module follows the "private by default" pattern — public access is disabled unless explicitly enabled.

### In Scope

- Key Vault creation with RBAC authorization
- Soft delete (always enabled in Azure, 7-90 day retention configurable)
- Purge protection (enabled by default)
- Private endpoint with single subresource (`vault`)
- Network ACLs for IP/VNet rules when public access is needed

### Out of Scope (Deferred)

- Access policies (deprecated in favor of RBAC)
- Secret/key/certificate creation (use `azurerm_key_vault_secret` etc. directly)
- Role assignments (consumer responsibility)
- Customer-managed keys for encryption
- HSM-backed keys (Premium SKU feature, defer to v1.1.0)

## Feature Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_private_endpoint` | bool | `true` | Create a private endpoint for the Key Vault |
| `enable_public_access` | bool | `false` | Allow public network access |
| `enable_purge_protection` | bool | `true` | Enable purge protection (cannot be disabled once enabled) |

## Private Endpoint Support

| Setting | Value |
|---------|-------|
| Subresource name | `vault` |
| Private DNS zone | `privatelink.vaultcore.azure.net` |

### Required Variables (when `enable_private_endpoint = true`)

| Variable | Type | Description |
|----------|------|-------------|
| `subnet_id` | string | Subnet ID for the private endpoint |
| `private_dns_zone_id` | string | Private DNS zone ID for `privatelink.vaultcore.azure.net` |

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `sku_name` | string | No | `"standard"` | SKU name (`standard` or `premium`) |
| `tenant_id` | string | No | Current tenant | Azure AD tenant ID for the Key Vault |
| `soft_delete_retention_days` | number | No | `90` | Soft delete retention period (7-90 days) |
| `enabled_for_deployment` | bool | No | `false` | Allow VMs to retrieve certificates |
| `enabled_for_disk_encryption` | bool | No | `false` | Allow Azure Disk Encryption to retrieve secrets |
| `enabled_for_template_deployment` | bool | No | `false` | Allow ARM templates to retrieve secrets |
| `network_acls` | object | No | `null` | Network ACLs for IP/VNet rules (see below) |

### Network ACLs Variable Structure

```hcl
variable "network_acls" {
  type = object({
    bypass                     = optional(string, "AzureServices")
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default     = null
  description = "Network ACLs for the Key Vault. Only applies when enable_public_access = true."
}
```

### Example Usage

```hcl
# Private access only (default)
module "key_vault" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//key-vault?ref=key-vault/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "kv-payments-dev-weu-001"
  tags                = local.common_tags

  subnet_id           = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id = module.private_dns.zone_ids["privatelink.vaultcore.azure.net"]
}

# With public access and network ACLs
module "key_vault_public" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//key-vault?ref=key-vault/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "kv-payments-dev-weu-001"
  tags                = local.common_tags

  enable_private_endpoint = false
  enable_public_access    = true

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
  }
}
```

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `vault_uri` | Key Vault URI (e.g., `https://kv-name.vault.azure.net/`) |
| `tenant_id` | Azure AD tenant ID |
| `private_endpoint_id` | Private endpoint resource ID (when enabled) |
| `private_ip_address` | Private IP address of the private endpoint (when enabled) |
| `public_vault_id` | Key Vault resource ID (for cross-project consumption) |
| `public_vault_uri` | Key Vault URI (for cross-project consumption) |

## Notes

- **RBAC only:** The module sets `enable_rbac_authorization = true` and does not support access policies. Access policies are deprecated and RBAC provides better auditability and integration with Azure AD.
- **Purge protection warning:** Once enabled, purge protection cannot be disabled. The vault cannot be permanently deleted until the retention period expires. This is intentional for production use but may be inconvenient in dev/test. Set `enable_purge_protection = false` for ephemeral environments.
- **Soft delete is mandatory:** Azure requires soft delete on all Key Vaults. The `soft_delete_retention_days` can be configured (7-90 days) but soft delete cannot be disabled.
- **Network ACLs vs private endpoint:** Network ACLs only apply when `enable_public_access = true`. When using private endpoints, network ACLs are typically not needed since the vault is only accessible via the private IP.
- **Tenant ID:** If not provided, the module uses the tenant ID from the current Azure subscription context.
