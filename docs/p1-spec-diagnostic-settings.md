# Module: diagnostic-settings

**Priority:** P1  
**Status:** Not Started  
**Target Version:** v1.0.0

## What It Creates

- `azurerm_monitor_diagnostic_setting` — Azure Monitor Diagnostic Setting

## v1.0.0 Scope

A standalone module for applying diagnostic settings to any Azure resource. This module is used selectively on high-value resources (application gateways, firewalls, AKS clusters, etc.), not on every resource.

### In Scope

- Diagnostic setting creation targeting a Log Analytics workspace
- Configurable log and metric categories
- Support for enabling all categories by default or selecting specific ones

### Out of Scope (Deferred)

- Storage account as destination (all diagnostics go to Log Analytics in v1.0.0)
- Event Hub as destination
- Partner solution destinations
- Multiple diagnostic settings per resource (consumers can call the module multiple times)

## Feature Flags

No feature flags for v1.0.0. The module is opt-in by nature — consumers only use it where needed.

## Private Endpoint Support

Not applicable. Diagnostic settings are a configuration resource, not a network resource.

## Variables

This module does not follow the standard interface (`resource_group_name`, `location`, `name`, `tags`) because diagnostic settings are child resources of their target — they inherit the target's resource group and location.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | string | Yes | — | Diagnostic setting name |
| `target_resource_id` | string | Yes | — | Resource ID of the resource to monitor |
| `log_analytics_workspace_id` | string | Yes | — | Destination Log Analytics workspace ID |
| `enabled_log_categories` | list(string) | No | `null` | Specific log categories to enable. `null` = all available categories. |
| `metric_categories` | list(string) | No | `null` | Specific metric categories to enable. `null` = all available categories. |
| `log_analytics_destination_type` | string | No | `null` | Destination type (Dedicated, null = AzureDiagnostics). Resource-specific tables (Dedicated) is recommended for supported resources. |

## Outputs

| Output | Description |
|--------|-------------|
| `id` | Diagnostic setting resource ID |
| `name` | Diagnostic setting name |

## Consumer Usage Examples

### Single Resource

```hcl
module "appgw_diagnostics" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//diagnostic-settings?ref=diagnostic-settings/v1.0.0"

  name                       = "diag-appgw-payments-dev-weu-001"
  target_resource_id         = module.application_gateway.id
  log_analytics_workspace_id = module.log_analytics.id
}
```

### Multiple Resources via for_each

```hcl
locals {
  monitored_resources = {
    appgw    = module.application_gateway.id
    firewall = module.firewall.id
    aks      = module.aks.id
  }
}

module "diagnostics" {
  for_each = local.monitored_resources
  source   = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//diagnostic-settings?ref=diagnostic-settings/v1.0.0"

  name                       = "diag-${each.key}-${var.project}-${var.environment}-${var.region_short}-001"
  target_resource_id         = each.value
  log_analytics_workspace_id = module.log_analytics.id
}
```

### Selective Log Categories

```hcl
module "kv_diagnostics" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//diagnostic-settings?ref=diagnostic-settings/v1.0.0"

  name                       = "diag-kv-payments-dev-weu-001"
  target_resource_id         = module.key_vault.id
  log_analytics_workspace_id = module.log_analytics.id
  enabled_log_categories     = ["AuditEvent", "AzurePolicyEvaluationDetails"]
}
```

## Notes

- **Non-standard interface:** This module intentionally breaks from the standard interface convention (`resource_group_name`, `location`, `tags`). Diagnostic settings are child resources that inherit their target's resource group and location. Requiring consumers to pass these would be redundant and error-prone.
- **All categories by default:** When `enabled_log_categories` or `metric_categories` is `null`, the module enables all available categories using `enabled_log` or `metric` dynamic blocks with the `allLogs` and `AllMetrics` category groups. This is the safest default — consumers can narrow down if needed.
- **Category discovery:** Azure log/metric categories vary by resource type and change over time. Using "all" avoids maintaining a list per resource type.
- **Tags:** The `azurerm_monitor_diagnostic_setting` resource does not support tags. The `tags` variable is not included.
