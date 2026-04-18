# log-analytics-workspace

**Complexity:** Low

Creates an Azure Log Analytics workspace with secure defaults for centralized logging and monitoring.

## Usage

```hcl
module "log_analytics" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/log-analytics-workspace?ref=log-analytics-workspace/v1.0.0"

  resource_group_name = "rg-monitoring-dev-weu-001"
  location            = "westeurope"
  name                = "log-monitoring-dev-weu-001"

  tags = local.common_tags
}
```

## Features

- Configurable SKU (default: PerGB2018)
- Data retention with validation (30-730 days)
- Daily ingestion quota/cap
- Internet ingestion and query access controls (disabled by default)

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Internet ingestion | Disabled | `enable_internet_ingestion` |
| Internet query | Disabled | `enable_internet_query` |
| Retention | 30 days | `retention_in_days` |
| Daily quota | Unlimited | `daily_quota_gb` |

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_workspace_id` | Log Analytics workspace resource ID (for cross-project consumption) |

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.62.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_daily_quota_gb"></a> [daily\_quota\_gb](#input\_daily\_quota\_gb) | Daily ingestion quota in GB (-1 for unlimited) | `number` | `-1` | no |
| <a name="input_enable_internet_ingestion"></a> [enable\_internet\_ingestion](#input\_enable\_internet\_ingestion) | Enable internet ingestion (default: disabled for security) | `bool` | `false` | no |
| <a name="input_enable_internet_query"></a> [enable\_internet\_query](#input\_enable\_internet\_query) | Enable internet query access (default: disabled for security) | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Log Analytics workspace name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Data retention in days (30-730) | `number` | `30` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU of the Log Analytics workspace | `string` | `"PerGB2018"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Log Analytics workspace resource ID |
| <a name="output_name"></a> [name](#output\_name) | Log Analytics workspace name |
| <a name="output_public_workspace_id"></a> [public\_workspace\_id](#output\_public\_workspace\_id) | Log Analytics workspace resource ID (for cross-project consumption) |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Log Analytics workspace GUID |
<!-- END_TF_DOCS -->

## Notes

- **Shared keys not exposed:** The `primary_shared_key` and `secondary_shared_key` are intentionally not exposed as outputs. Use RBAC or managed identity for workspace access.
- **CMK encryption:** Customer-managed key encryption will be added in a future version.
- **AMPLS:** Azure Monitor Private Link Scope integration will be added in a future version.
- **Solutions:** Log Analytics solutions (e.g., SecurityInsights) are not managed by this module.
