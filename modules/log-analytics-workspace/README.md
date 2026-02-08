# log-analytics-workspace

**Complexity:** Simple

Creates an Azure Log Analytics workspace with secure defaults for centralized logging and monitoring.

## Usage

```hcl
module "log_analytics" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//log-analytics-workspace?ref=log-analytics-workspace/v1.0.0"

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

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **Shared keys not exposed:** The `primary_shared_key` and `secondary_shared_key` are intentionally not exposed as outputs. Use RBAC or managed identity for workspace access.
- **CMK encryption:** Customer-managed key encryption will be added in a future version.
- **AMPLS:** Azure Monitor Private Link Scope integration will be added in a future version.
- **Solutions:** Log Analytics solutions (e.g., SecurityInsights) are not managed by this module.
