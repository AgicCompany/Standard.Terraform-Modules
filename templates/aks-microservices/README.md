# AKS microservices platform

Generic reusable pattern for an AKS cluster ready to host microservices:
its own subnet, an extra user node pool, an image registry, a workload
identity, secrets, and Container Insights logging.

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
| 1 | `virtual-network` | Network, provides the AKS subnet |
| 2 | `aks` | Cluster (system node pool) |
| 3 | `aks-node-pool` | Additional user node pool |
| 4 | `container-registry` | Image registry (ACR) |
| 5 | `user-assigned-identity` | Workload identity |
| 6 | `key-vault` | Secrets (e.g. CSI Secrets Store driver) |
| 7 | `log-analytics-workspace` | Log sink for Container Insights |

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Per each module's `composition_contract`:

- `aks.default_node_pool.vnet_subnet_id` → subnet on `virtual-network` (#1)
- `aks-node-pool.kubernetes_cluster_id` → `aks` (#2)

The user node pool (#3) is deliberately not given its own
`node_pools.<key>.vnet_subnet_id`: AKS places an additional pool in the
cluster subnet when it is omitted. Set it explicitly in `terraform.tfvars`
if a pool needs a different subnet.

## Recommended optional bindings

Not required by the contract, but standard for this pattern:

- `aks.user_assigned_identity_ids` → `user-assigned-identity` (#5)
- `aks.log_analytics_workspace_id` / `aks.diagnostic_settings.log_analytics_workspace_id` → `log-analytics-workspace` (#7), for Container Insights

## Operational step outside Terraform

`container-registry` (#4) has no composition-contract binding to `aks` — ACR
pull access is granted via an `AcrPull` role assignment to the AKS
kubelet identity (or the workload identity in #5), done after deployment,
not wired in the graph.

## Not included (optional, future variant)

Private endpoints and private DNS zones for AKS/ACR, and NSG/route-table
associations on the virtual network, are supported by these modules but
left unwired here to keep this a straightforward starting point. A
"hardened" variant would add `private-dns-zone`, `network-security-group`,
and the corresponding private-endpoint bindings.
