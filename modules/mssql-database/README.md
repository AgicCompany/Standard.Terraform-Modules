# mssql-database

**Complexity:** Medium

Creates an Azure SQL Database on an existing SQL server with configurable SKU, backup retention, and optional zone redundancy.

## Usage

```hcl
module "db" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/mssql-database?ref=mssql-database/v1.0.0"

  name      = "payments-api"
  server_id = module.sql_server.id
  sku_name  = "S0"

  tags = local.common_tags
}
```

## Features

- SQL Database creation on an existing server (`azurerm_mssql_database`)
- Configurable SKU supporting both DTU and vCore purchasing models
- Short-term backup retention (point-in-time restore, 1-35 days)
- Geo-redundant backup storage (enabled by default)
- Zone redundancy support via feature flag
- Read scale-out support via feature flag
- License type configuration for Azure Hybrid Benefit

## Non-Standard Interface

This module does **not** include `resource_group_name` or `location` variables. SQL databases inherit both from their parent SQL server.

## Security Defaults

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Geo-redundant backup | Enabled | `enable_geo_redundant_backup` |

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_database_id` | SQL Database resource ID (for cross-project consumption) |
| `public_database_name` | SQL Database name (for cross-project consumption) |

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_mssql_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_collation"></a> [collation](#input\_collation) | Database collation | `string` | `"SQL_Latin1_General_CP1_CI_AS"` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Optional diagnostic settings. null disables. Supports multi-sink (Log Analytics, storage account, Event Hub). enabled\_log\_categories = null -> all categories the resource supports. enabled\_metrics = null -> all metrics the resource supports. At least one of log\_analytics\_workspace\_id, storage\_account\_id, or eventhub\_authorization\_rule\_id is required when the object is non-null. | <pre>object({<br/>    name                           = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    enabled_log_categories         = optional(list(string))<br/>    enabled_metrics                = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_enable_geo_redundant_backup"></a> [enable\_geo\_redundant\_backup](#input\_enable\_geo\_redundant\_backup) | Enable geo-redundant backup storage | `bool` | `true` | no |
| <a name="input_enable_read_scale"></a> [enable\_read\_scale](#input\_enable\_read\_scale) | Enable read-only replicas for read scale-out | `bool` | `false` | no |
| <a name="input_enable_zone_redundancy"></a> [enable\_zone\_redundancy](#input\_enable\_zone\_redundancy) | Enable zone redundant deployment | `bool` | `false` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License type: LicenseIncluded or BasePrice (Azure Hybrid Benefit) | `string` | `"LicenseIncluded"` | no |
| <a name="input_max_size_gb"></a> [max\_size\_gb](#input\_max\_size\_gb) | Maximum database size in GB | `number` | `2` | no |
| <a name="input_name"></a> [name](#input\_name) | Database name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_server_id"></a> [server\_id](#input\_server\_id) | ID of the SQL server to create the database on | `string` | n/a | yes |
| <a name="input_short_term_retention_days"></a> [short\_term\_retention\_days](#input\_short\_term\_retention\_days) | Point-in-time restore retention in days (1-35) | `number` | `7` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Database SKU (e.g., S0, P1, GP\_Gen5\_2, HS\_Gen5\_2, BC\_Gen5\_2) | `string` | `"S0"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | SQL Database resource ID |
| <a name="output_name"></a> [name](#output\_name) | SQL Database name |
| <a name="output_public_database_id"></a> [public\_database\_id](#output\_public\_database\_id) | SQL Database resource ID (for cross-project consumption) |
| <a name="output_public_database_name"></a> [public\_database\_name](#output\_public\_database\_name) | SQL Database name (for cross-project consumption) |
<!-- END_TF_DOCS -->

## Notes

- **No `resource_group_name` or `location`** -- inherited from parent server.
- **Private endpoints** are managed at the server level (`mssql-server` module).
- **Default SKU `S0`** is suitable for dev/test. Production typically uses `S1`+ or vCore SKUs.
- **Collation** cannot be changed after creation.
- **Zone redundancy** is only available for Premium (`P*`) and Business Critical (`BC_*`) SKUs.
