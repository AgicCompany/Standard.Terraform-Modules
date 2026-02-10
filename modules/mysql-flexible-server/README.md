# mysql-flexible-server

**Complexity:** Medium

Creates an Azure MySQL Flexible Server with configurable databases, firewall rules, and server parameters.

## Usage

```hcl
module "mysql" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//mysql-flexible-server?ref=mysql-flexible-server/v1.0.0"

  resource_group_name    = "rg-myapp-dev-weu-001"
  location               = "westeurope"
  name                   = "mysql-myapp-dev-weu-001"
  administrator_login    = "mysqladmin"
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

- MySQL Flexible Server with configurable SKU and version (5.7, 8.0.21)
- Database management via for_each map
- Server configuration parameters via for_each map
- Firewall rules via for_each map
- VNet integration via delegated subnet (not traditional PE)
- High availability (SameZone / ZoneRedundant)
- Custom maintenance window
- Geo-redundant backups

## Security Defaults

- Public network access disabled by default
- TLS enforced by Azure (minimum TLS 1.2 on Flexible Server)

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **VNet integration vs Private Endpoint:** MySQL Flexible Server uses VNet integration (delegated subnet) rather than traditional private endpoints. The subnet must have delegation `Microsoft.DBforMySQL/flexibleServers`.
- **Private DNS Zone:** When using VNet integration, a private DNS zone (e.g., `privatelink.mysql.database.azure.com`) must be linked to the VNet. The consumer is responsible for creating the DNS zone and VNet link.
- **Storage:** Storage size cannot be decreased after creation. The `auto_grow_enabled` setting allows automatic storage growth.
- **Firewall rules:** Only applicable when the server is NOT VNet-integrated (public access mode).
- **High availability:** Requires General Purpose or Memory Optimized SKUs. Not available on Burstable SKUs.
- **Default version:** MySQL 8.0.21 is the default. Version 5.7 is also supported.
