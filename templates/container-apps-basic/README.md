# Container Apps basic

Generic reusable pattern for running containers without Kubernetes: a
VNet-integrated Container Apps environment with one app, an image
registry, a workload identity, and Log Analytics.


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
| 3 | `container-app` | The application (quickstart image, 0.25 vCPU / 0.5 GiB) |
| 4 | `container-registry` | Image registry (ACR) |
| 5 | `user-assigned-identity` | Workload identity for the app |
| 6 | `virtual-network` | `aca` infrastructure subnet (/23) for the environment |

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Per each module's `composition_contract`:

- `container-app-environment.log_analytics_workspace_id` → `log-analytics-workspace` (#1)
- `container-app.container_app_environment_id` → `container-app-environment` (#2)

## Recommended optional bindings

- `container-app.user_assigned_identity_ids` → `user-assigned-identity` (#5)
- `container-app-environment.infrastructure_subnet_id` → `aca` subnet on
  `virtual-network` (#6). Optional per the contract but effectively
  mandatory today: the module always emits
  `internal_load_balancer_enabled` / `zone_redundancy_enabled`, which
  azurerm rejects without `infrastructure_subnet_id`. Upstream module bug,
  tracked separately.

## Operational step outside Terraform

`container-registry` (#4) has no contract binding to `container-app` —
grant `AcrPull` to the workload identity (#5) after deployment and set
`registry` on the app to pull from it. The quickstart image is public.

## Not included (optional, future variant)

Private endpoints for ACR, an internal (ILB) environment, Key Vault for
secrets, and diagnostic settings — all supported by these modules, left
unwired to keep this a minimal starting point.
