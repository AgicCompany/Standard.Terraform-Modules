# Linux VM jump box

Generic reusable pattern for a single Linux VM reachable only through
Bastion: its own VNet and subnet, an NSG, and no public IP.


## Usage

This directory is a complete Terraform root: `main.tf` wires the modules
together (sources pinned to released module tags), `versions.tf` holds the
provider and an empty `azurerm` backend block, and
`terraform.tfvars.example.json` carries a working set of input values.

```bash
cp terraform.tfvars.example.json terraform.tfvars.json
# edit names, resource group, location, tags
# and replace linux_virtual_machine_vm.admin_ssh_public_key with YOUR public key
terraform init -backend-config=<your-backend.hcl>
terraform plan
```

The resource group is not created by the template — it must exist before
`apply`. Names in the example follow CAF conventions; change the `myapp`
token to your workload name.

## Resources

| # | Module | Role |
|---|--------|------|
| 1 | `virtual-network` | `vm` subnet (/24) + `AzureBastionSubnet` (/26) |
| 2 | `network-security-group` | NSG for the `vm` subnet |
| 3 | `linux-virtual-machine` | The VM (`Standard_B2s`, SSH key auth only) |
| 4 | `bastion` | Secure remote access |

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Per each module's `composition_contract`:

- `linux-virtual-machine.subnet_id` → `vm` subnet on `virtual-network` (#1)
- `bastion.subnet_id` → `AzureBastionSubnet` on `virtual-network` (#1)

## Deliberately unwired

- `virtual-network.subnet_nsg_associations` (NSG → subnet) is not wired —
  same as in `networking-hub-baseline`. Associate the NSG in
  `terraform.tfvars` or after deployment.
- `admin_ssh_public_key` ships as a throwaway placeholder key whose private
  half was never kept; replace it before deploying.

## Not included (optional, future variant)

Boot diagnostics storage, a user-assigned identity, Log Analytics / VM
insights, and a NAT gateway for egress — supported, left out on purpose.
