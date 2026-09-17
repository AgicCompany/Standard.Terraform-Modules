# Static web app + API

Generic reusable pattern for a static frontend with a serverless API: a
Static Web App plus a Flex Consumption Function App, with monitoring.


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
| 1 | `static-web-app` | Frontend (public, no private endpoint) |
| 2 | `app-service-plan` | Flex Consumption plan for the API |
| 3 | `storage-account` | Function App runtime storage |
| 4 | `function-app-flex` | The API (Python 3.12) |
| 5 | `log-analytics-workspace` | Log sink, required by Application Insights |
| 6 | `application-insights` | Monitoring |

`function-app-flex` is used instead of `function-app` on purpose: the
classic module requires a literal `storage_account_access_key` and
`storage-account` exposes no key output, so it cannot be wired without
shipping a secret placeholder.

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Per each module's `composition_contract`:

- `function-app-flex.service_plan_id` → `app-service-plan` (#2)
- `function-app-flex.storage_container_endpoint` → `storage-account` (#3)
- `application-insights.workspace_id` → `log-analytics-workspace` (#5)

## Operational step outside Terraform

Linking the Static Web App to the Function App as its backend ("bring
your own API") is a SWA-side configuration, not a module binding — do it
after deployment. `application_insights_connection_string` on the
function is a sensitive output and is not exposed for wiring; set it in
`terraform.tfvars` from the App Insights resource.

## Not included (optional, future variant)

Private endpoints and VNet integration for the SWA and the function, a
user-assigned identity, and diagnostic settings — supported, left out to
keep this a minimal public-facing starting point.
