# Web app + DB

Generic reusable pattern for a PaaS web app backed by a managed database,
cache, secrets store, and monitoring.

## Usage

This directory is a complete Terraform root: `main.tf` wires the modules
together (sources pinned to released module tags), `versions.tf` holds the
provider and an empty `azurerm` backend block, and
`terraform.tfvars.example.json` carries a working set of input values.

```bash
cp terraform.tfvars.example.json terraform.tfvars.json
# edit names, resource group, location, tags
# and set postgresql_flexible_server_db.administrator_password (never commit it)
terraform init -backend-config=<your-backend.hcl>
terraform plan
```

The resource group is not created by the template — it must exist before
`apply`. Names in the example follow CAF conventions; change the `myapp`
token to your workload name.

## Resources

| # | Module | Role |
|---|--------|------|
| 1 | `app-service-plan` | Hosting plan for the web app |
| 2 | `linux-web-app` | Application |
| 3 | `postgresql-flexible-server` | Primary database |
| 4 | `redis-cache` | Cache / session store |
| 5 | `key-vault` | Secrets |
| 6 | `log-analytics-workspace` | Log sink, required by Application Insights |
| 7 | `application-insights` | App monitoring |

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Only two bindings are mandatory (per each module's `composition_contract`);
everything else in these modules is optional.

- `linux-web-app.service_plan_id` → `app-service-plan` (#1)
- `application-insights.workspace_id` → `log-analytics-workspace` (#6)

## Not included (optional, future variant)

Private endpoints, VNet integration, and diagnostic settings are supported
by these modules but left unwired here to keep this a minimal, no-networking
starting point. A "hardened" variant (VNet + private endpoints + diagnostics
wired on every module) would need `virtual-network`, `private-dns-zone`, and
per-module diagnostic bindings added — worth its own template later.
