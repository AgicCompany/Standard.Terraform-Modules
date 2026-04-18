# postgresql-flexible-server

**Complexity:** Medium

Creates an Azure PostgreSQL Flexible Server with configurable databases, firewall rules, and server parameters.

## Usage

```hcl
module "postgresql" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/postgresql-flexible-server?ref=postgresql-flexible-server/v4.0.0"

  resource_group_name    = "rg-myapp-dev-weu-001"
  location               = "westeurope"
  name                   = "psql-myapp-dev-weu-001"
  administrator_login    = "psqladmin"
  administrator_password = var.admin_password

  # PE is default — provide subnet and DNS zone
  subnet_id           = module.vnet.subnet_ids["snet-pe"]
  private_dns_zone_id = module.dns.zone_ids["privatelink.postgres.database.azure.com"]

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
- Private endpoint support (default, mutually exclusive with VNet delegation)
- VNet integration via delegated subnet (alternative to PE)
- Database management via for_each map
- Server configuration parameters via for_each map
- Firewall rules via for_each map
- High availability (SameZone / ZoneRedundant)
- Custom maintenance window
- Entra ID (AAD) authentication support
- Geo-redundant backups

## Security Defaults

- Public network access disabled by default
- Password authentication enabled by default
- TLS enforced by Azure (minimum TLS 1.2 on Flexible Server)

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_postgresql_server_id` | PostgreSQL Flexible Server resource ID (for cross-project consumption) |
| `public_postgresql_server_name` | PostgreSQL Flexible Server name (for cross-project consumption) |
| `public_postgresql_server_fqdn` | PostgreSQL Flexible Server FQDN (for cross-project consumption) |

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
| [azurerm_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_configuration.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_postgresql_flexible_server_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_administrator_login"></a> [administrator\_login](#input\_administrator\_login) | Administrator login name. Required when authentication.password\_auth\_enabled = true. | `string` | `null` | no |
| <a name="input_administrator_password"></a> [administrator\_password](#input\_administrator\_password) | Administrator password. Required when authentication.password\_auth\_enabled = true. | `string` | `null` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Backup retention days (7-35) | `number` | `7` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | Map of databases to create. Key is used as the database name. | <pre>map(object({<br/>    charset   = optional(string, "UTF8")<br/>    collation = optional(string, "en_US.utf8")<br/>  }))</pre> | `{}` | no |
| <a name="input_delegated_subnet_id"></a> [delegated\_subnet\_id](#input\_delegated\_subnet\_id) | Subnet ID for VNet integration (requires Microsoft.DBforPostgreSQL/flexibleServers delegation). Mutually exclusive with private endpoint. | `string` | `null` | no |
| <a name="input_enable_entra_auth"></a> [enable\_entra\_auth](#input\_enable\_entra\_auth) | Enable Microsoft Entra (AAD) authentication (default: enabled for security) | `bool` | `true` | no |
| <a name="input_enable_password_auth"></a> [enable\_password\_auth](#input\_enable\_password\_auth) | Enable password authentication. Disabled by default; use Entra ID where possible. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for the PostgreSQL server. Mutually exclusive with VNet delegation (delegated\_subnet\_id). | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access (default: disabled for security) | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Map of firewall rules. Key is used as the rule name. Only applicable when not VNet-integrated. | <pre>map(object({<br/>    start_ip_address = string<br/>    end_ip_address   = string<br/>  }))</pre> | `{}` | no |
| <a name="input_geo_redundant_backup_enabled"></a> [geo\_redundant\_backup\_enabled](#input\_geo\_redundant\_backup\_enabled) | Enable geo-redundant backups | `bool` | `false` | no |
| <a name="input_high_availability"></a> [high\_availability](#input\_high\_availability) | High availability configuration. Mode must be 'SameZone' or 'ZoneRedundant'. | <pre>object({<br/>    mode                      = string<br/>    standby_availability_zone = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Custom maintenance window | <pre>object({<br/>    day_of_week  = optional(number, 0)<br/>    start_hour   = optional(number, 0)<br/>    start_minute = optional(number, 0)<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | PostgreSQL Flexible Server name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID (privatelink.postgres.database.azure.com). Required when using delegation or private endpoint. | `string` | `null` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Override the private endpoint resource name. Defaults to pep-{name}. | `string` | `null` | no |
| <a name="input_private_endpoint_nic_name"></a> [private\_endpoint\_nic\_name](#input\_private\_endpoint\_nic\_name) | Override the PE network interface name. Defaults to pep-{name}-nic. | `string` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Override the private service connection name. Defaults to psc-{name}. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_server_configurations"></a> [server\_configurations](#input\_server\_configurations) | Map of server configuration parameters. Key is the parameter name, value is the parameter value. | `map(string)` | `{}` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the PostgreSQL Flexible Server (e.g., B\_Standard\_B1ms, GP\_Standard\_D2s\_v3, MO\_Standard\_E4s\_v3) | `string` | `"B_Standard_B1ms"` | no |
| <a name="input_storage_mb"></a> [storage\_mb](#input\_storage\_mb) | Storage size in MB (32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 8388608, 16777216) | `number` | `32768` | no |
| <a name="input_storage_tier"></a> [storage\_tier](#input\_storage\_tier) | Storage tier (P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80). Auto-selected if null. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_version_number"></a> [version\_number](#input\_version\_number) | PostgreSQL major version | `string` | `"16"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Availability zone (1, 2, or 3) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_ids"></a> [database\_ids](#output\_database\_ids) | Map of database names to database resource IDs |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | Fully qualified domain name of the PostgreSQL server |
| <a name="output_id"></a> [id](#output\_id) | PostgreSQL Flexible Server resource ID |
| <a name="output_name"></a> [name](#output\_name) | PostgreSQL Flexible Server name |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_postgresql_server_fqdn"></a> [public\_postgresql\_server\_fqdn](#output\_public\_postgresql\_server\_fqdn) | PostgreSQL Flexible Server FQDN (for cross-project consumption) |
| <a name="output_public_postgresql_server_id"></a> [public\_postgresql\_server\_id](#output\_public\_postgresql\_server\_id) | PostgreSQL Flexible Server resource ID (for cross-project consumption) |
| <a name="output_public_postgresql_server_name"></a> [public\_postgresql\_server\_name](#output\_public\_postgresql\_server\_name) | PostgreSQL Flexible Server name (for cross-project consumption) |
<!-- END_TF_DOCS -->

## Notes

- **Private endpoint (default):** Since v2.0.0, PE is the default private connectivity mode. The consumer provides a PE subnet (no delegation needed) and a private DNS zone (`privatelink.postgres.database.azure.com`).
- **VNet delegation (alternative):** Set `enable_private_endpoint = false` and provide `delegated_subnet_id` to use the delegation model. The subnet must have delegation `Microsoft.DBforPostgreSQL/flexibleServers`. PE and delegation are mutually exclusive.
- **Private DNS Zone:** Required for both PE and delegation modes. The consumer is responsible for creating the DNS zone and VNet link.
- **Storage:** Storage size cannot be decreased after creation. The `storage_tier` is auto-selected based on `storage_mb` if not specified.
- **Firewall rules:** Only applicable when the server is NOT VNet-integrated (public access mode).
- **High availability:** Requires General Purpose or Memory Optimized SKUs. Not available on Burstable SKUs.
