# Container Apps jobs

Scheduled batch work without Kubernetes: the `container-apps-basic`
environment with a cron-triggered Container Apps job instead of a
long-running app.


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
| 1 | `log-analytics-workspace` | Log sink, required by the environment |
| 2 | `container-app-environment` | Managed environment (Consumption) |
| 3 | `container-app-job` | The job (quickstart image, cron `0 2 * * *`, 30 min timeout) |
| 4 | `container-registry` | Image registry (ACR) |
| 5 | `user-assigned-identity` | Workload identity for the job |
| 6 | `virtual-network` | `aca` infrastructure subnet (/23) for the environment |

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Per each module's `composition_contract`:

- `container-app-environment.log_analytics_workspace_id` → `log-analytics-workspace` (#1)
- `container-app-job.container_app_environment_id` → `container-app-environment` (#2)

## Recommended optional bindings

- `container-app-job.user_assigned_identity_ids` → `user-assigned-identity` (#5)
- `container-app-environment.infrastructure_subnet_id` → `aca` subnet on
  `virtual-network` (#6) — VNet-integrated environment, same choice as
  `container-apps-basic`.

## Operational step outside Terraform

`container-registry` (#4) has no contract binding to the job — grant
`AcrPull` to the workload identity (#5) after deployment and point the job
at your image. The quickstart image is public.

## Not included (optional, future variant)

Event-triggered (KEDA) or manual jobs — change `schedule_trigger_config`
to `event_trigger_config` / `manual_trigger_config`. Private ACR, Key
Vault for job secrets, diagnostic settings — supported, left out.
