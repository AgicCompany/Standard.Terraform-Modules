# Module: mssql-server

**Priority:** P2
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_mssql_server` — Azure SQL Server (logical server)
- `azurerm_private_endpoint` — Private endpoint (when `enable_private_endpoint = true`)
- `azurerm_private_endpoint_dns_zone_group` — DNS zone group (when `enable_private_endpoint = true`)

## v1.0.0 Scope

An Azure SQL logical server with secure defaults, Azure AD authentication, and private endpoint support. The server is the management container for databases — individual databases are created via the `mssql-database` module.

### In Scope

- SQL logical server creation
- Azure AD administrator configuration (required)
- SQL administrator login/password from Key Vault
- Secure defaults (minimum TLS 1.2, public access disabled)
- Private endpoint for `sqlServer` subresource
- Connection policy configuration
- Outbound networking restriction

### Out of Scope (Deferred)

- Firewall rules (consumers create `azurerm_mssql_firewall_rule` directly)
- Virtual network rules
- Vulnerability assessments
- Security alert policies
- Auditing (use the standalone `diagnostic-settings` module)
- Failover groups (add when HA requirements arise)
- Elastic pools (separate module consideration)
- Transparent Data Encryption (TDE) with customer-managed key

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_private_endpoint` | `true` | Create a private endpoint for this SQL server |
| `enable_public_access` | `false` | Allow public network access |
| `enable_aad_only_auth` | `true` | Restrict authentication to Azure AD only (no SQL auth). See notes. |

## Private Endpoint Support

| Property | Value |
|----------|-------|
| Subresource name | `sqlServer` |
| Private DNS zone | `privatelink.database.windows.net` |

### Variables (Private Endpoint)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `subnet_id` | string | Conditional | — | Subnet ID for private endpoint. Required when `enable_private_endpoint = true`. |
| `private_dns_zone_id` | string | Conditional | — | Private DNS zone ID. Required when `enable_private_endpoint = true`. |

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `version` | string | No | `"12.0"` | SQL Server version. `12.0` is the only currently supported value. |
| `administrator_login` | string | Conditional | — | SQL admin username. Required when `enable_aad_only_auth = false`. |
| `administrator_login_password` | string | Conditional | — | SQL admin password. Required when `enable_aad_only_auth = false`. Retrieved from Key Vault by consumer. |
| `azuread_administrator` | object | Yes | — | Azure AD administrator configuration (see below) |
| `minimum_tls_version` | string | No | `"1.2"` | Minimum TLS version |
| `connection_policy` | string | No | `"Default"` | Connection policy: `Default`, `Proxy`, or `Redirect` |

### Azure AD Administrator Variable Structure

```hcl
variable "azuread_administrator" {
  type = object({
    login_username              = string
    object_id                   = string
    azuread_authentication_only = optional(bool, true)
  })
  default     = null
  description = "Azure AD administrator. Required."
}
```

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `fully_qualified_domain_name` | FQDN of the SQL server |
| `principal_id` | System-assigned managed identity principal ID |
| `tenant_id` | System-assigned managed identity tenant ID |
| `private_endpoint_id` | Private endpoint resource ID (when enabled) |
| `private_ip_address` | Private IP address of the endpoint (when enabled) |
| `public_sql_server_id` | SQL server ID (public output) |
| `public_sql_server_name` | SQL server name (public output) |
| `public_sql_server_fqdn` | SQL server FQDN (public output) |

## Deferred

- **Failover groups** — `azurerm_mssql_failover_group` for HA. Requires a secondary server. Significant complexity.
- **Elastic pools** — `azurerm_mssql_elasticpool` for shared resource management across databases. Consider as a separate module.
- **TDE with CMK** — Transparent Data Encryption with customer-managed keys via Key Vault.
- **Vulnerability assessment** — `azurerm_mssql_server_vulnerability_assessment`. Requires a storage account for scan results.
- **Firewall rules** — Consumers create these directly when public access is needed (dev/test scenarios).

## Notes

- **Azure AD-only authentication:** Default is `enable_aad_only_auth = true`, which disables SQL authentication entirely. This is the Microsoft-recommended security posture. When enabled, `administrator_login` and `administrator_login_password` are not required (and ignored by Azure). When disabled, SQL auth is available alongside Azure AD auth, and the SQL admin credentials must be provided.
- **SQL admin password from Key Vault:** When SQL auth is enabled, the consumer retrieves the admin password from Key Vault using a `data.azurerm_key_vault_secret` block and passes it to this module. The module does not interact with Key Vault directly — that's the consumer's responsibility. This follows the pattern documented in the key-vault module spec.
- **Naming constraint:** SQL server names must be globally unique, 1-63 characters, lowercase alphanumeric and hyphens. CAF prefix: `sql`. Example: `sql-payments-dev-weu-001`.
- **`version = "12.0"`:** This is the only version currently supported by Azure. The variable exists for forward compatibility.
- **Connection policy:** `Default` uses Redirect within Azure and Proxy from outside Azure. `Redirect` has better performance for Azure-to-Azure connections. `Proxy` forces all connections through the Azure SQL gateway. For private endpoint access, `Default` is fine.
- **System-assigned identity:** Always enabled on the server to support features like TDE with CMK and Azure AD integration. This is not a feature flag — it's an Azure best practice.
- **Relationship to mssql-database:** This module creates the logical server. The `mssql-database` module creates individual databases within the server. The server `id` output is the link between them.
