# Networking / hub baseline

Generic reusable shared network foundation — a VNet with a hardened
workload subnet, managed egress, secure remote access, and a private DNS
zone other templates' modules can link into.

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
| 1 | `virtual-network` | Hub network: a workload subnet + `AzureBastionSubnet` |
| 2 | `network-security-group` | Attached to the workload subnet |
| 3 | `route-table` | Attached to the workload subnet (e.g. force egress via NAT) |
| 4 | `nat-gateway` | Managed outbound internet egress |
| 5 | `bastion` | Secure RDP/SSH access into the VNet |
| 6 | `private-dns-zone` | Linked to the VNet, for other templates' privatelink zones |

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Per each module's `composition_contract`:

- `bastion.subnet_id` → `AzureBastionSubnet` on `virtual-network` (#1)

## Recommended optional bindings

Wired via `virtual-network`'s own subnet-association fields, not the other
module's contract:

- `virtual-network.subnet_nsg_associations` → `network-security-group` (#2) on the workload subnet
- `virtual-network.subnet_route_table_associations` → `route-table` (#3) on the workload subnet
- `private-dns-zone.virtual_network_links.virtual_network_id` → `virtual-network` (#1)

## Operational step outside Terraform

`nat-gateway` (#4) has no composition-contract binding to a subnet — NAT
gateway-to-subnet association is set at the topology/placement level (the
blueprint's `topology` section), not as a variable binding between modules.

## How this baseline is meant to be used

This template is the shared network other templates plug into: point the
web-app-db, AKS microservices, or serverless templates' `subnet_id` /
`private_dns_zone_id` optional bindings at this VNet and zone instead of
leaving them unwired, once private endpoints or VNet integration are
needed.
