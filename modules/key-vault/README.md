# key-vault

**Complexity:** Low

Creates an Azure Key Vault with RBAC authorization and optional private endpoint.

## Usage

```hcl
module "key_vault" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//key-vault?ref=key-vault/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "kv-payments-dev-weu-001"

  # Private endpoint (required inputs when enable_private_endpoint = true)
  subnet_id           = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id = module.private_dns.zone_ids["privatelink.vaultcore.azure.net"]

  tags = local.common_tags
}
```

## Features

- RBAC authorization (access policies not supported)
- Soft delete with configurable retention (7-90 days)
- Purge protection (enabled by default, disable for dev/test)
- Private endpoint with DNS integration
- Network ACLs for public access scenarios
- VM integration flags for deployment, disk encryption, and ARM templates

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| RBAC authorization | Enabled | (not configurable) |
| Public network access | Disabled | `enable_public_access` |
| Purge protection | Enabled | `enable_purge_protection` |
| Soft delete retention | 90 days | `soft_delete_retention_days` |
| Private endpoint | Enabled | `enable_private_endpoint` |

## Private Endpoint

When `enable_private_endpoint = true` (default), the following inputs are required:

| Variable | Description |
|----------|-------------|
| `subnet_id` | Subnet ID for the private endpoint |
| `private_dns_zone_id` | Private DNS zone ID for `privatelink.vaultcore.azure.net` |

The module creates the private endpoint and configures DNS zone group registration.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_vault_id` | Key Vault resource ID |
| `public_vault_uri` | Key Vault URI |

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **RBAC only:** This module uses RBAC authorization exclusively. Access policies are deprecated and not supported.
- **Purge protection warning:** Once enabled, purge protection cannot be disabled. The vault cannot be permanently deleted until the retention period expires. Set `enable_purge_protection = false` for ephemeral dev/test environments.
- **Soft delete is mandatory:** Azure requires soft delete on all Key Vaults. The retention period can be configured but soft delete cannot be disabled.
- **Secret retrieval:** Access keys and secrets are not exposed as outputs. Consumers should retrieve secrets via data sources or grant RBAC access to applications.
