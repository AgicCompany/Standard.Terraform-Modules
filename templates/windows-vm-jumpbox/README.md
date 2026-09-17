# Windows VM jump box

Windows twin of `linux-vm-jumpbox`: a single Windows VM reachable only
through Bastion, with its own VNet and subnet, an NSG, and no public IP.

## Usage

This directory is a complete Terraform root: `main.tf` wires the modules
together (sources pinned to released module tags), `versions.tf` holds the
provider and an empty `azurerm` backend block, and
`terraform.tfvars.example.json` carries a working set of input values.

```bash
cp terraform.tfvars.example.json terraform.tfvars.json
# edit names, resource group, location, tags
# and replace windows_virtual_machine_vm.admin_password (never commit it)
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
| 3 | `windows-virtual-machine` | The VM (`Standard_B2s`, local admin password) |
| 4 | `bastion` | Secure remote access (RDP via Bastion) |

## Required bindings

Already wired in `main.tf`; listed here so the shape of the graph is explicit.

Per each module's `composition_contract`:

- `windows-virtual-machine.subnet_id` → `vm` subnet on `virtual-network` (#1)
- `bastion.subnet_id` → `AzureBastionSubnet` on `virtual-network` (#1)

## Recommended optional bindings

- `virtual-network.subnet_nsg_associations` (`map_key: vm`) →
  `network-security-group` (#2) — wired, same as the Linux jump box.

## Values to replace

- `admin_password` ships as the placeholder `CHANGE_ME`; `terraform plan`
  refuses it (Azure password complexity), which is the point — replace it
  (ideally from Key Vault) before deploying.

## Not included (optional, future variant)

Boot diagnostics storage, a user-assigned identity, Log Analytics / VM
insights, and a NAT gateway for egress — supported, left out on purpose.
