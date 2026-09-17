# Serverless / event-driven

Generic reusable pattern for a Flex Consumption Function App triggered by
a queue, writing to a document store, with monitoring.

## Usage

This directory is a complete Terraform root: `main.tf` wires the modules
together (sources pinned to released module tags), `versions.tf` holds the
provider and an empty `azurerm` backend block, and
`terraform.tfvars.example.json` carries a working set of input values.

```bash
cp terraform.tfvars.example.json terraform.tfvars.json
# edit names, resource group, location, tags
terraform init -backend-config=<your-backend.hcl>
terraform plan
```

The resource group is not created by the template — it must exist before
`apply`. Names in the example follow CAF conventions; change the `myapp`
token to your workload name.

## Resources

| # | Module | Role |
|---|--------|------|
| 1 | `app-service-plan` | Flex Consumption / Premium hosting plan |
| 2 | `storage-account` | Function app storage |
| 3 | `function-app-flex` | Function app |
| 4 | `service-bus` | Queue/topic trigger for the function |
| 5 | `cosmosdb` | Data store for function output |
| 6 | `log-analytics-workspace` | Log sink, required by Application Insights |
| 7 | `application-insights` | App monitoring |

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Per each module's `composition_contract`:

- `function-app-flex.service_plan_id` → `app-service-plan` (#1)
- `function-app-flex.storage_container_endpoint` → `storage-account` (#2)
- `application-insights.workspace_id` → `log-analytics-workspace` (#6)

`service-bus` (#4) and `cosmosdb` (#5) have no composition-contract binding
into `function-app-flex` — the queue/topic connection string and Cosmos
connection are wired as function-level trigger/output bindings (or
`app_settings` referencing Key Vault), not as a graph edge.

## Not included (optional, future variant)

Private endpoints/VNet integration for the function app, storage, service
bus, and cosmos, plus `event-hub` as an alternative or additional trigger
for streaming/telemetry ingestion (vs. service-bus's queue-based
messaging), are left out here to keep this a minimal starting point.
