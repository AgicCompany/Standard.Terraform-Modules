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
<!-- END_TF_DOCS -->

## Notes

- **All logs by default:** When `enabled_log_categories` is `null` (default), the module uses the `allLogs` category group to capture all available log categories.
- **Selective categories:** Pass a list of specific category names to `enabled_log_categories` to enable only those categories.
- **Dedicated tables:** Set `log_analytics_destination_type = "Dedicated"` to use resource-specific tables in Log Analytics, which provide better query performance and schema.
- **Multiple targets:** Create multiple instances of this module to send diagnostics from the same resource to multiple destinations.
