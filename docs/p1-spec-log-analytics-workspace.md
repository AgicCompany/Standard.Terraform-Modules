# Module: log-analytics-workspace

**Priority:** P1  
**Status:** Not Started  
**Target Version:** v1.0.0

## What It Creates

- `azurerm_log_analytics_workspace` — Azure Log Analytics Workspace

## v1.0.0 Scope

A Log Analytics workspace with configurable SKU and retention. This is a foundational module — most other modules and the standalone `diagnostic-settings` module depend on a workspace existing.

### In Scope

- Workspace creation with configurable SKU and retention
- Internet ingestion and query access controls
- Daily cap configuration

### Out of Scope (Deferred)

- Log Analytics solutions (consumers add solutions directly)
- Linked storage accounts
- Data export rules
- Workspace-based Application Insights (consumers create directly)
- Cross-workspace queries (consumer responsibility)
- Customer-managed key (CMK) encryption
- Workspace cluster association

## Feature Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_internet_ingestion` | bool | `false` | Allow ingestion from public networks |
| `enable_internet_query` | bool | `false` | Allow queries from public networks |

## Private Endpoint Support

Not applicable for v1.0.0. Log Analytics workspace private link scope (AMPLS) is a more complex pattern involving `azurerm_monitor_private_link_scope` and is deferred.

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `sku` | string | No | `"PerGB2018"` | Pricing tier (Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018) |
| `retention_in_days` | number | No | `30` | Data retention in days (30-730) |
| `daily_quota_gb` | number | No | `-1` | Daily ingestion cap in GB (-1 = unlimited) |

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `workspace_id` | Log Analytics workspace ID (the GUID, not the Azure resource ID) |
| `primary_shared_key` | — |
| `public_workspace_id` | Log Analytics workspace resource ID (for cross-project consumption) |

**Forbidden outputs:** `primary_shared_key`, `secondary_shared_key`. Consumers retrieve these via data source if needed.

## Notes

- **SKU default:** `PerGB2018` is the current standard pay-as-you-go SKU. The legacy SKUs (Free, Standalone, PerNode) are mostly deprecated for new workspaces.
- **Retention:** Default 30 days is the minimum for the PerGB2018 SKU. Consumers can increase up to 730 days. Retention beyond 30 days incurs additional cost.
- **Internet access:** Both ingestion and query access default to disabled. Consumers can enable these for dev/test scenarios or when Azure Monitor Private Link Scope is not in use.
- **AMPLS (Azure Monitor Private Link Scope):** Full private access to Log Analytics requires AMPLS, which is a separate resource that links to the workspace. This is deferred from v1.0.0 due to complexity. Consumers can configure AMPLS at the project level.
- **Workspace ID vs Resource ID:** The `workspace_id` output is the GUID (used in agent configurations and API calls), while `id` is the full Azure resource ID (used in Terraform references). Both are needed by consumers.
