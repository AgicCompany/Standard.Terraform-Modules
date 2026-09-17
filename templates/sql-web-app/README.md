# SQL web app

Generic reusable pattern for a PaaS web app backed by Azure SQL — the
Microsoft-stack twin of `web-app-db` (PostgreSQL): hosting plan, web app,
SQL server + database, secrets store, and monitoring.


## Usage

This directory is a complete Terraform root: `main.tf` wires the modules
together (sources pinned to released module tags), `versions.tf` holds the
provider and an empty `azurerm` backend block, and
`terraform.tfvars.example.json` carries a working set of input values.

```bash
cp terraform.tfvars.example.json terraform.tfvars.json
# edit names, resource group, location, tags
# and set mssql_server_sql.azuread_administrator to a real Entra group
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
| 3 | `mssql-server` | Logical SQL server (Entra-only auth) |
| 4 | `mssql-database` | The database |
| 5 | `key-vault` | Secrets |
| 6 | `log-analytics-workspace` | Log sink, required by Application Insights |
| 7 | `application-insights` | App monitoring |

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Per each module's `composition_contract`:

- `linux-web-app.service_plan_id` → `app-service-plan` (#1)
- `mssql-database.server_id` → `mssql-server` (#3)
- `application-insights.workspace_id` → `log-analytics-workspace` (#6)

## Values to replace

`mssql-server.azuread_administrator` ships with a placeholder
`object_id` (all zeros) and `login_username` `sql-admins`; set it to a real
Entra group before deploying. Entra-only auth is on, so there is no SQL
password to manage.

## Not included (optional, future variant)

Private endpoints, VNet integration, and diagnostic settings — supported by
these modules, left unwired to keep this a minimal, no-networking starting
point, exactly like `web-app-db`.
