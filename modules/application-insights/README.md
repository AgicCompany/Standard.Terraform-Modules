# application-insights

**Complexity:** Low

Creates an Azure Application Insights resource backed by a Log Analytics workspace for application performance monitoring (APM).

## Usage

```hcl
module "application_insights" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//application-insights?ref=application-insights/v1.0.0"

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

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **Workspace-based only:** This module requires a Log Analytics workspace ID. Classic (standalone) Application Insights is deprecated by Microsoft.
- **Instrumentation key deprecation:** Microsoft recommends using the connection string instead of the instrumentation key. Both are exposed as sensitive outputs.
- **Sampling:** Set `sampling_percentage` below 100 to reduce data volume and costs for high-traffic applications.
- **Function App / Web App integration:** Pass `output.connection_string` to the function-app or linux-web-app module's `app_settings` as `APPLICATIONINSIGHTS_CONNECTION_STRING`.
