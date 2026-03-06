# application-insights

**Complexity:** Low

Creates an Azure Application Insights resource backed by a Log Analytics workspace for application performance monitoring (APM).

## Usage

```hcl
module "application_insights" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//application-insights?ref=application-insights/v1.0.0"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "appi-myapp-dev-weu-001"
  workspace_id        = module.log_analytics.id

  tags = var.tags
}
```

## Features

- Workspace-based Application Insights (classic mode deprecated by Microsoft)
- Configurable application type (web, java, Node.JS, etc.)
- Data retention and daily cap configuration
- Sampling percentage control
- Local authentication toggle
- Connection string and instrumentation key outputs (sensitive)

## Security Defaults

- IP masking enabled by default (client IPs are anonymized)
- Local authentication enabled by default (set `local_authentication_disabled = true` for AAD-only)
- Internet ingestion and query enabled by default (required for most application telemetry scenarios)

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_app_insights_id` | Application Insights resource ID (for cross-project consumption) |
| `public_connection_string` | Application Insights connection string (for cross-project consumption) |

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
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | Application type | `string` | `"web"` | no |
| <a name="input_daily_data_cap_in_gb"></a> [daily\_data\_cap\_in\_gb](#input\_daily\_data\_cap\_in\_gb) | Daily data volume cap in GB (null for unlimited) | `number` | `null` | no |
| <a name="input_daily_data_cap_notifications_disabled"></a> [daily\_data\_cap\_notifications\_disabled](#input\_daily\_data\_cap\_notifications\_disabled) | Disable notifications when daily data cap is hit | `bool` | `false` | no |
| <a name="input_disable_ip_masking"></a> [disable\_ip\_masking](#input\_disable\_ip\_masking) | Disable IP masking in logs | `bool` | `false` | no |
| <a name="input_force_customer_storage_for_profiler"></a> [force\_customer\_storage\_for\_profiler](#input\_force\_customer\_storage\_for\_profiler) | Force customer storage for profiler data | `bool` | `false` | no |
| <a name="input_internet_ingestion_enabled"></a> [internet\_ingestion\_enabled](#input\_internet\_ingestion\_enabled) | Enable ingestion over public internet. Disabled by default for security. | `bool` | `false` | no |
| <a name="input_internet_query_enabled"></a> [internet\_query\_enabled](#input\_internet\_query\_enabled) | Enable querying over public internet. Disabled by default for security. | `bool` | `false` | no |
| <a name="input_local_authentication_disabled"></a> [local\_authentication\_disabled](#input\_local\_authentication\_disabled) | Disable local (non-AAD) authentication. Disabled by default for security; set to false to allow API key auth. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Application Insights name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Data retention in days | `number` | `90` | no |
| <a name="input_sampling_percentage"></a> [sampling\_percentage](#input\_sampling\_percentage) | Percentage of telemetry items to sample (0-100) | `number` | `100` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | Log Analytics workspace resource ID (required for workspace-based Application Insights) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | Application Insights application ID |
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | Application Insights connection string |
| <a name="output_id"></a> [id](#output\_id) | Application Insights resource ID |
| <a name="output_instrumentation_key"></a> [instrumentation\_key](#output\_instrumentation\_key) | Application Insights instrumentation key |
| <a name="output_name"></a> [name](#output\_name) | Application Insights name |
| <a name="output_public_app_insights_id"></a> [public\_app\_insights\_id](#output\_public\_app\_insights\_id) | Application Insights resource ID (for cross-project consumption) |
| <a name="output_public_connection_string"></a> [public\_connection\_string](#output\_public\_connection\_string) | Application Insights connection string (for cross-project consumption) |
<!-- END_TF_DOCS -->

## Notes

- **Workspace-based only:** This module requires a Log Analytics workspace ID. Classic (standalone) Application Insights is deprecated by Microsoft.
- **Instrumentation key deprecation:** Microsoft recommends using the connection string instead of the instrumentation key. Both are exposed as sensitive outputs.
- **Sampling:** Set `sampling_percentage` below 100 to reduce data volume and costs for high-traffic applications.
- **Function App / Web App integration:** Pass `output.connection_string` to the function-app or linux-web-app module's `app_settings` as `APPLICATIONINSIGHTS_CONNECTION_STRING`.
