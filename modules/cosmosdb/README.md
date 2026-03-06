# cosmosdb

**Complexity:** Medium

Creates an Azure Cosmos DB account with SQL API databases and optional private endpoint.

## Usage

```hcl
module "cosmosdb" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/cosmosdb?ref=cosmosdb/v1.1.0"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "cosmos-myapp-dev-weu-001"

  sql_databases = {
    appdb = {}
  }

  enable_private_endpoint = false
  enable_public_access    = true

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

## Features

- Cosmos DB account with SQL API (GlobalDocumentDB)
- SQL database management via for_each map
- Autoscale throughput support for databases
- Configurable consistency policy
- Multi-region geo-replication
- Automatic failover support
- Private endpoint with DNS zone integration
- Periodic and continuous backup policies
- IP firewall rules
- Free tier support
- Entra ID (AAD) and key-based authentication

## Security Defaults

- Public network access disabled by default
- Private endpoint enabled by default
- TLS 1.2 minimum
- Local authentication enabled by default (set `enable_local_auth = false` for AAD-only)

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_cosmosdb_id` | Cosmos DB account resource ID (for cross-project consumption) |
| `public_cosmosdb_name` | Cosmos DB account name (for cross-project consumption) |
| `public_cosmosdb_endpoint` | Cosmos DB account endpoint (for cross-project consumption) |

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
| [azurerm_cosmosdb_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_sql_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automatic_failover_enabled"></a> [automatic\_failover\_enabled](#input\_automatic\_failover\_enabled) | Enable automatic failover for the account | `bool` | `false` | no |
| <a name="input_backup"></a> [backup](#input\_backup) | Backup policy configuration | <pre>object({<br/>    type                = optional(string, "Periodic")<br/>    interval_in_minutes = optional(number, 240)<br/>    retention_in_hours  = optional(number, 8)<br/>    storage_redundancy  = optional(string, "Geo")<br/>    tier                = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Account capacity configuration (total throughput limit in RU/s, -1 for unlimited) | <pre>object({<br/>    total_throughput_limit = number<br/>  })</pre> | `null` | no |
| <a name="input_consistency_policy"></a> [consistency\_policy](#input\_consistency\_policy) | Consistency policy configuration | <pre>object({<br/>    consistency_level       = string<br/>    max_interval_in_seconds = optional(number, 5)<br/>    max_staleness_prefix    = optional(number, 100)<br/>  })</pre> | <pre>{<br/>  "consistency_level": "Session"<br/>}</pre> | no |
| <a name="input_enable_local_auth"></a> [enable\_local\_auth](#input\_enable\_local\_auth) | Enable local (key-based) authentication. Disabled by default; use Entra ID where possible. | `bool` | `false` | no |
| <a name="input_enable_multiple_write_locations"></a> [enable\_multiple\_write\_locations](#input\_enable\_multiple\_write\_locations) | Enable multi-region writes | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for this Cosmos DB account | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access (default: disabled for security) | `bool` | `false` | no |
| <a name="input_free_tier_enabled"></a> [free\_tier\_enabled](#input\_free\_tier\_enabled) | Enable Cosmos DB free tier (one per subscription) | `bool` | `false` | no |
| <a name="input_geo_locations"></a> [geo\_locations](#input\_geo\_locations) | List of geo-locations for the Cosmos DB account. If null, uses the primary location with failover\_priority 0. | <pre>list(object({<br/>    location          = string<br/>    failover_priority = number<br/>    zone_redundant    = optional(bool, false)<br/>  }))</pre> | `null` | no |
| <a name="input_ip_range_filter"></a> [ip\_range\_filter](#input\_ip\_range\_filter) | Set of CIDR IP ranges to allow through the Cosmos DB firewall | `set(string)` | `[]` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Cosmos DB account kind | `string` | `"GlobalDocumentDB"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_minimal_tls_version"></a> [minimal\_tls\_version](#input\_minimal\_tls\_version) | Minimum TLS version | `string` | `"Tls12"` | no |
| <a name="input_name"></a> [name](#input\_name) | Cosmos DB account name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_offer_type"></a> [offer\_type](#input\_offer\_type) | Cosmos DB offer type | `string` | `"Standard"` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.documents.azure.com. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sql_databases"></a> [sql\_databases](#input\_sql\_databases) | Map of SQL API databases to create. Key is used as the database name. | <pre>map(object({<br/>    throughput     = optional(number, null)<br/>    max_throughput = optional(number, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_ids"></a> [database\_ids](#output\_database\_ids) | Map of database names to database resource IDs |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Cosmos DB account endpoint URL |
| <a name="output_id"></a> [id](#output\_id) | Cosmos DB account resource ID |
| <a name="output_name"></a> [name](#output\_name) | Cosmos DB account name |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_cosmosdb_endpoint"></a> [public\_cosmosdb\_endpoint](#output\_public\_cosmosdb\_endpoint) | Cosmos DB account endpoint (for cross-project consumption) |
| <a name="output_public_cosmosdb_id"></a> [public\_cosmosdb\_id](#output\_public\_cosmosdb\_id) | Cosmos DB account resource ID (for cross-project consumption) |
| <a name="output_public_cosmosdb_name"></a> [public\_cosmosdb\_name](#output\_public\_cosmosdb\_name) | Cosmos DB account name (for cross-project consumption) |
<!-- END_TF_DOCS -->

## Notes

- **Free tier:** Only one Cosmos DB account per subscription can use free tier. Set `free_tier_enabled = true` to use it.
- **Consistency levels:** BoundedStaleness requires `max_interval_in_seconds` and `max_staleness_prefix`. Other levels ignore these fields.
- **Geo-locations:** If `geo_locations` is null, the account is created with a single region (the primary location). For multi-region, specify at least two locations with different failover priorities.
- **Backup:** Periodic backup is the default. For continuous backup (point-in-time restore), set `backup.type = "Continuous"`.
- **SQL API only:** This module creates SQL API databases. For MongoDB, Cassandra, Gremlin, or Table API, the account kind and database resources would need to be different.
- **Provisioning time:** Cosmos DB accounts can take 5-15 minutes to provision, especially with geo-replication.
