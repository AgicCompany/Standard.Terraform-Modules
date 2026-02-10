# postgresql-flexible-server

**Complexity:** Medium

Creates an Azure PostgreSQL Flexible Server with configurable databases, firewall rules, and server parameters.

## Usage

```hcl
module "postgresql" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//postgresql-flexible-server?ref=postgresql-flexible-server/v1.0.0"

  resource_group_name    = "rg-myapp-dev-weu-001"
  location               = "westeurope"
  name                   = "psql-myapp-dev-weu-001"
  administrator_login    = "psqladmin"
  administrator_password = var.admin_password

  databases = {
    appdb = {}
  }

  tags = {
    Environment = "dev"
  }
}
```

## Features

- PostgreSQL Flexible Server with configurable SKU and version (12-16)
- Database management via for_each map
- Server configuration parameters via for_each map
- Firewall rules via for_each map
- VNet integration via delegated subnet (not traditional PE)
- High availability (SameZone / ZoneRedundant)
- Custom maintenance window
- Entra ID (AAD) authentication support
- Geo-redundant backups

## Security Defaults

- Public network access disabled by default
- Password authentication enabled by default
- TLS enforced by Azure (minimum TLS 1.2 on Flexible Server)

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **VNet integration vs Private Endpoint:** PostgreSQL Flexible Server uses VNet integration (delegated subnet) rather than traditional private endpoints. The subnet must have delegation `Microsoft.DBforPostgreSQL/flexibleServers`.
- **Private DNS Zone:** When using VNet integration, a private DNS zone (e.g., `privatelink.postgres.database.azure.com`) must be linked to the VNet. The consumer is responsible for creating the DNS zone and VNet link.
- **Storage:** Storage size cannot be decreased after creation. The `storage_tier` is auto-selected based on `storage_mb` if not specified.
- **Firewall rules:** Only applicable when the server is NOT VNet-integrated (public access mode).
- **High availability:** Requires General Purpose or Memory Optimized SKUs. Not available on Burstable SKUs.
