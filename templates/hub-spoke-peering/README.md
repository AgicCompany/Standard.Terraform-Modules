# Hub-spoke peering

Generic reusable pattern for the first step beyond a single VNet: a hub
and a spoke, peered both ways, with a route table and NSG ready for the
spoke workload subnet.


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
| 1 | `virtual-network` (`hub`) | `10.0.0.0/16`, `shared` subnet (/24) |
| 2 | `virtual-network` (`spoke`) | `10.1.0.0/16`, `workload` subnet (/24) |
| 3 | `vnet-peering` | Bidirectional hub ↔ spoke peering |
| 4 | `route-table` | For the spoke workload subnet (e.g. default route via a hub firewall) |
| 5 | `network-security-group` | For the spoke workload subnet |

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Per each module's `composition_contract`:

- `vnet-peering.virtual_network_id` → `hub` (#1)
- `vnet-peering.remote_virtual_network_id` → `spoke` (#2)

The peering's VNet names and resource groups are **not** inputs — `main.tf`
derives them from the VNet ids with `split("/", ...)`, so pointing
`remote_virtual_network_id` at an existing VNet in another resource group
needs no other change.

## Deliberately unwired

- `virtual-network.subnet_route_table_associations` /
  `subnet_nsg_associations` (RT/NSG → spoke subnet) are not wired — same
  as the hub baseline and the jump boxes. Associate them in
  `terraform.tfvars` or after deployment.

## Not included (optional, future variant)

A hub firewall / NVA, Bastion in the hub, private DNS zones linked to
both VNets, and a second spoke — all supported by the catalogue, left out
to keep this the minimal two-VNet starting point.
