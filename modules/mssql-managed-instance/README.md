# mssql-managed-instance

**Complexity:** High

Creates an Azure SQL Managed Instance with secure defaults, always-on transparent data encryption, Advanced Threat Protection, and optional diagnostics.

> **Provisioning time:** create, scale and delete operations on a SQL Managed Instance take hours (up to 24 h; the first instance in a subnet is slowest). Terraform blocks for the whole run — plan CI/agent timeouts accordingly. The module keeps the provider's 24 h timeouts; override via `timeouts` if you need shorter hard limits.

## Usage

```hcl
module "sql_managed_instance" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/mssql-managed-instance?ref=mssql-managed-instance/v1.0.0"

  resource_group_name = "rg-sql-prod-weu-001"
  location            = "westeurope"
  name                = "sqlmi-payments-prod-weu-001"

  # Sizing is deliberately required — no defaults
  subnet_id          = module.vnet.subnet_ids["snet-sqlmi"]
  sku_name           = "GP_Gen5"
  vcores             = 4
  storage_size_in_gb = 32

  azuread_administrator = {
    login_username = "sqlmi-admins"
    object_id      = "00000000-0000-0000-0000-000000000000"
    principal_type = "Group"
  }

  tags = local.common_tags
}
```

## Features

- SQL Managed Instance (General Purpose / Business Critical, Gen5 and Gen8 hardware)
- Microsoft Entra ID administrator (required) with Entra-only authentication by default
- Optional SQL administrator login for mixed authentication
- System-assigned and/or user-assigned managed identity
- Transparent data encryption, always configured: service-managed or customer-managed key (Key Vault, optional auto-rotation)
- Advanced Threat Protection with email notifications
- Zone redundancy, next-gen General Purpose tier, backup storage redundancy, connection type, time zone and maintenance window controls
- `dns_zone_partner_id` pass-through for building failover-group pairs
- Optional multi-sink diagnostic settings

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Entra-only authentication | Enabled | `enable_aad_only_auth` |
| Public data endpoint | Disabled | `enable_public_data_endpoint` |
| Minimum TLS version | 1.2 (only accepted value) | `min_tls_version` |
| Transparent data encryption | Enabled, service-managed key | `customer_managed_key` |
| Advanced Threat Protection | Enabled | `enable_security_alert_policy`, `security_alert_policy` |
| Managed identity | SystemAssigned | `identity` |
| Zone redundancy | Disabled (cost) | `enable_zone_redundancy` |

## Network Prerequisites

The module does **not** create networking. Before applying, the consumer must provide a subnet that:

- is dedicated to SQL Managed Instance (no other resource types),
- is delegated to `Microsoft.Sql/managedInstances`,
- has a network security group **and** a route table associated (Azure's service-aided subnet configuration injects the rules and routes it needs),
- is at least a `/27` (a `/26` or larger is recommended for scaling headroom).

Use the `virtual-network`, `network-security-group` and `route-table` modules, and add a `depends_on` from this module to the subnet associations so the instance is not created before they exist. See `examples/basic`.

## Customer-Managed TDE Key

When `customer_managed_key` is set:

- The Key Vault must have soft delete and purge protection enabled.
- The instance identity (system-assigned principal, or the user-assigned identity in `identity.identity_ids`) needs `Get`, `WrapKey` and `UnwrapKey` on the key — the *Key Vault Crypto Service Encryption User* role on RBAC vaults. Grant it **before** the instance is created (user-assigned identity), or in a second apply (system-assigned).
- Use a versioned key ID unless `auto_rotation_enabled = true`; with auto-rotation a versionless ID is allowed and the deploying principal must be able to read the latest key version.
- TDE can never be removed once enabled. Setting `customer_managed_key` back to `null` switches to a service-managed key in place.

See `examples/complete` for a full Key Vault + user-assigned identity wiring.

## Public Outputs

These outputs are designed for cross-project state consumption:

- `public_managed_instance_id`
- `public_managed_instance_name`
- `public_managed_instance_fqdn`

## Tests

`tests/validation.tftest.hcl` runs offline against a mocked provider and covers every input validation and precondition:

```bash
terraform init -backend=false
terraform test
```

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
