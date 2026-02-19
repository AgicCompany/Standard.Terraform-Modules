# mysql-flexible-server

**Complexity:** Medium

Creates an Azure MySQL Flexible Server with configurable databases, firewall rules, and server parameters.

## Usage

```hcl
module "mysql" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//mysql-flexible-server?ref=mysql-flexible-server/v2.0.0"

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
- Private endpoint support (default, mutually exclusive with VNet delegation)
- VNet integration via delegated subnet (alternative to PE)
- Database management via for_each map
- Server configuration parameters via for_each map
- Firewall rules via for_each map
- High availability (SameZone / ZoneRedundant)
- Custom maintenance window
- Geo-redundant backups

## Security Defaults

- Public network access disabled by default
- TLS enforced by Azure (minimum TLS 1.2 on Flexible Server)

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_mysql_server_id` | MySQL Flexible Server resource ID (for cross-project consumption) |
| `public_mysql_server_name` | MySQL Flexible Server name (for cross-project consumption) |
| `public_mysql_server_fqdn` | MySQL Flexible Server FQDN (for cross-project consumption) |

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_mysql_flexible_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_database) | resource |
| [azurerm_mysql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server) | resource |
| [azurerm_mysql_flexible_server_configuration.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_configuration) | resource |
| [azurerm_mysql_flexible_server_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_firewall_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | Administrator login name | `string` | `null` | no |
| <a name="input_administrator_password"></a> [administrator\_password](#input\_administrator\_password) | Administrator password | `string` | `null` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Backup retention days (1-35) | `number` | `7` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | Map of databases to create. Key is used as the database name. | <pre>map(object({<br/>    charset   = optional(string, "utf8mb4")<br/>    collation = optional(string, "utf8mb4_unicode_ci")<br/>  }))</pre> | `{}` | no |
| <a name="input_delegated_subnet_id"></a> [delegated\_subnet\_id](#input\_delegated\_subnet\_id) | Subnet ID for VNet integration (requires Microsoft.DBforMySQL/flexibleServers delegation). Mutually exclusive with public access. | `string` | `null` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access (default: disabled for security) | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Map of firewall rules. Key is used as the rule name. Only applicable when not VNet-integrated. | <pre>map(object({<br/>    start_ip_address = string<br/>    end_ip_address   = string<br/>  }))</pre> | `{}` | no |
| <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled) | Enable geo-redundant backups | `bool` | `false` | no |
| <a name="input_high_availability"></a> [high\_availability](#input\_high\_availability) | High availability configuration. Mode must be 'SameZone' or 'ZoneRedundant'. | <pre>object({<br/>    mode                      = string<br/>    standby_availability_zone = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Custom maintenance window | <pre>object({<br/>    day_of_week  = optional(number, 0)<br/>    start_hour   = optional(number, 0)<br/>    start_minute = optional(number, 0)<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | MySQL Flexible Server name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for VNet-integrated server (e.g., privatelink.mysql.database.azure.com). Required when delegated\_subnet\_id is set. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_server_configurations"></a> [server\_configurations](#input\_server\_configurations) | Map of server configuration parameters. Key is the parameter name, value is the parameter value. | `map(string)` | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the MySQL Flexible Server (e.g., B\_Standard\_B1ms, GP\_Standard\_D2ds\_v4, MO\_Standard\_E4s\_v3) | `string` | `"B_Standard_B1ms"` | no |
| <a name="input_storage"></a> [storage](#input\_storage) | Storage configuration for the MySQL Flexible Server | <pre>object({<br/>    size_gb           = optional(number, 20)<br/>    iops              = optional(number)<br/>    auto_grow_enabled = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_version_number"></a> [version\_number](#input\_version\_number) | MySQL version | `string` | `"8.0.21"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Availability zone (1, 2, or 3) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_ids"></a> [database\_ids](#output\_database\_ids) | Map of database names to database resource IDs |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | Fully qualified domain name of the MySQL server |
| <a name="output_id"></a> [id](#output\_id) | MySQL Flexible Server resource ID |
| <a name="output_name"></a> [name](#output\_name) | MySQL Flexible Server name |
| <a name="output_public_mysql_server_fqdn"></a> [public\_mysql\_server\_fqdn](#output\_public\_mysql\_server\_fqdn) | MySQL Flexible Server FQDN (for cross-project consumption) |
| <a name="output_public_mysql_server_id"></a> [public\_mysql\_server\_id](#output\_public\_mysql\_server\_id) | MySQL Flexible Server resource ID (for cross-project consumption) |
| <a name="output_public_mysql_server_name"></a> [public\_mysql\_server\_name](#output\_public\_mysql\_server\_name) | MySQL Flexible Server name (for cross-project consumption) |
<!-- END_TF_DOCS -->

## Notes

- **Private endpoint (default):** Since v2.0.0, PE is the default private connectivity mode. The consumer provides a PE subnet (no delegation needed) and a private DNS zone (`privatelink.mysql.database.azure.com`).
- **VNet delegation (alternative):** Set `enable_private_endpoint = false` and provide `delegated_subnet_id` to use the delegation model. The subnet must have delegation `Microsoft.DBforMySQL/flexibleServers`. PE and delegation are mutually exclusive.
- **Private DNS Zone:** Required for both PE and delegation modes. The consumer is responsible for creating the DNS zone and VNet link.
- **Storage:** Storage size cannot be decreased after creation. The `auto_grow_enabled` setting allows automatic storage growth.
- **Firewall rules:** Only applicable when the server is NOT VNet-integrated (public access mode).
- **High availability:** Requires General Purpose or Memory Optimized SKUs. Not available on Burstable SKUs.
- **Default version:** MySQL 8.0.21 is the default. Version 5.7 is also supported.
