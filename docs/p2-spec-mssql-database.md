# Module: mssql-database

**Priority:** P2
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_mssql_database` — Azure SQL Database

## v1.0.0 Scope

An individual SQL database within an existing Azure SQL server. Supports common configurations for DTU and vCore purchasing models.

### In Scope

- Database creation on an existing SQL server
- Configurable SKU (DTU-based and vCore-based)
- Short-term backup retention
- Long-term backup retention (optional)
- Geo-redundant backup (optional)
- Zone redundancy (optional)
- Collation configuration
- License type for vCore (Azure Hybrid Benefit)
- Read scale (Premium/Business Critical)

### Out of Scope (Deferred)

- Elastic pool membership (add when elastic pool module exists)
- Transparent Data Encryption with customer-managed key
- Import/export operations
- Ledger database
- Threat detection policies
- Diagnostic settings (use the standalone `diagnostic-settings` module)
- Long-term retention policies (evaluate for v1.1.0)

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_zone_redundancy` | `false` | Enable zone redundant deployment. Premium/Business Critical SKUs only. |
| `enable_geo_redundant_backup` | `true` | Enable geo-redundant backup storage. Security default. |
| `enable_read_scale` | `false` | Enable read-only replicas for read scale-out. Premium/Business Critical SKUs only. |

## Private Endpoint Support

Not applicable. Private endpoints are managed at the SQL server level (`mssql-server` module), not the database level. All databases on a server share the same private endpoint.

## Variables

Beyond the standard interface. Note: `resource_group_name` and `location` are **not required** — the database inherits these from the server. The standard `name` variable is required.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `server_id` | string | Yes | — | ID of the SQL server to create the database on |
| `sku_name` | string | No | `"S0"` | Database SKU. See notes for valid values. |
| `max_size_gb` | number | No | `2` | Maximum database size in GB |
| `collation` | string | No | `"SQL_Latin1_General_CP1_CI_AS"` | Database collation |
| `license_type` | string | No | `"LicenseIncluded"` | License type: `LicenseIncluded` or `BasePrice` (Azure Hybrid Benefit) |
| `short_term_retention_days` | number | No | `7` | Point-in-time restore retention in days (1-35) |
| `tags` | map(string) | No | `{}` | Tags to apply to the database |

## Outputs

Beyond `id` and `name`:

| Output | Description |
|--------|-------------|
| `public_database_id` | Database ID (public output) |
| `public_database_name` | Database name (public output) |

## Deferred

- **Elastic pool membership** — `elastic_pool_id` variable. Requires the elastic pool module to exist first.
- **TDE with CMK** — Customer-managed key encryption at the database level.
- **Long-term retention** — Weekly, monthly, yearly backup retention policies.
- **Threat detection** — `azurerm_mssql_database_extended_auditing_policy` and threat detection settings.
- **Import from bacpac** — Initial data load from a bacpac file.
- **Ledger** — `ledger_enabled` for tamper-proof database. Immutable after creation.

## Notes

- **Reduced standard interface:** This module does not require `resource_group_name` or `location` — the database inherits both from the parent SQL server. Only `name`, `server_id`, and `tags` from the standard interface are included. This is a documented deviation, similar to `diagnostic-settings`.
- **SKU values (DTU-based):** `Basic`, `S0`, `S1`, `S2`, `S3`, `S4`, `S6`, `S7`, `S9`, `S12`, `P1`, `P2`, `P4`, `P6`, `P11`, `P15`. These define the DTU capacity.
- **SKU values (vCore-based):** `GP_S_Gen5_1`, `GP_Gen5_2`, `GP_Gen5_4`, `BC_Gen5_2`, `HS_Gen5_2`, etc. Format: `{tier}_{family}_{capacity}`. GP = General Purpose, BC = Business Critical, HS = Hyperscale.
- **Default SKU `S0`:** Standard tier, 10 DTUs. Suitable for dev/test. Production typically uses `S1`+ or vCore SKUs. Consumers override per environment.
- **Geo-redundant backup:** Defaults to `true` (security default). This is Azure's recommendation. Disabling it reduces cost but limits disaster recovery options to the primary region only.
- **Zone redundancy:** Only available for Premium (`P*`) and Business Critical (`BC_*`) SKUs. Cannot be changed after creation on some SKU tiers.
- **Read scale:** Available on Premium and Business Critical SKUs. Provides a read-only replica for offloading read queries.
- **Collation:** Cannot be changed after database creation. The default `SQL_Latin1_General_CP1_CI_AS` is the Azure default and supports most Western European languages.
- **License type:** `LicenseIncluded` means Azure provides the SQL license (pay more per hour). `BasePrice` applies Azure Hybrid Benefit if the organization has existing SQL Server licenses (pay less per hour). This is a cost optimization choice.
- **Naming:** No CAF prefix required — database names are scoped to the server and need only be unique within it. Example: `payments-api`, `payments-reporting`.
- **Relationship to mssql-server:** The `server_id` comes from the `mssql-server` module's output. The database cannot exist without a server.
