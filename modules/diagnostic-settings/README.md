# diagnostic-settings

**Complexity:** Low

Creates an Azure Monitor diagnostic setting to send logs and metrics from any Azure resource to a Log Analytics workspace.

## Usage

```hcl
module "diag" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//diagnostic-settings?ref=diagnostic-settings/v1.0.0"

  name                       = "diag-kv-payments-dev-weu-001"
  target_resource_id         = module.key_vault.id
  log_analytics_workspace_id = module.log_analytics.id
}
```

## Features

- Diagnostic setting targeting Log Analytics workspace
- All log categories enabled by default (via `allLogs` category group)
- All metric categories enabled by default (via `AllMetrics` category group)
- Selective category configuration for fine-grained control
- Resource-specific (Dedicated) or legacy (AzureDiagnostics) table support

## Security Defaults

This module sends all available logs and metrics by default:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Log categories | All (allLogs group) | `enabled_log_categories` |
| Metric categories | All (AllMetrics group) | `metric_categories` |
| Destination type | Provider default | `log_analytics_destination_type` |

## Non-Standard Interface

This module does **not** include `resource_group_name`, `location`, or `tags` variables. Diagnostic settings are child resources attached to a target resource and do not have their own resource group, location, or tags.

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled_log_categories"></a> [enabled\_log\_categories](#input\_enabled\_log\_categories) | List of log categories to enable. Null sends all logs via the allLogs category group. | `list(string)` | `null` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Log Analytics destination type. Use "Dedicated" for resource-specific tables or "AzureDiagnostics" for legacy single table. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace resource ID for log destination | `string` | n/a | yes |
| <a name="input_metric_categories"></a> [metric\_categories](#input\_metric\_categories) | List of metric categories to enable. Null sends all metrics via the AllMetrics category group. | `list(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Diagnostic setting name | `string` | n/a | yes |
| <a name="input_target_resource_id"></a> [target\_resource\_id](#input\_target\_resource\_id) | Resource ID of the target resource to monitor | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Diagnostic setting resource ID |
| <a name="output_name"></a> [name](#output\_name) | Diagnostic setting name |
<!-- END_TF_DOCS -->

## Notes

- **All logs by default:** When `enabled_log_categories` is `null` (default), the module uses the `allLogs` category group to capture all available log categories.
- **Selective categories:** Pass a list of specific category names to `enabled_log_categories` to enable only those categories.
- **Dedicated tables:** Set `log_analytics_destination_type = "Dedicated"` to use resource-specific tables in Log Analytics, which provide better query performance and schema.
- **Multiple targets:** Create multiple instances of this module to send diagnostics from the same resource to multiple destinations.
