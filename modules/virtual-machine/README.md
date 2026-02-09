# virtual-machine

**Complexity:** Medium

Creates an Azure Linux Virtual Machine with network interface, optional public IP, and data disk management.

## Usage

```hcl
module "virtual_machine" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//virtual-machine?ref=virtual-machine/v1.0.0"

  resource_group_name  = "rg-compute-dev-weu-001"
  location             = "westeurope"
  name                 = "vm-app-dev-weu-001"
  size                 = "Standard_B1s"
  subnet_id            = module.vnet.subnet_ids["snet-compute"]
  admin_username       = "azureuser"
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")

  tags = local.common_tags
}
```

## Features

- Linux VM with SSH key authentication (password auth disabled)
- Network interface with configurable IP allocation
- Optional public IP address
- Data disk management with for_each
- Configurable source image (defaults to Ubuntu 22.04 LTS Gen2)
- System and user-assigned managed identity support
- Boot diagnostics support
- Availability zone support

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Password auth | Disabled | N/A (SSH-only) |
| Public IP | None | `enable_public_ip` |
| OS disk type | Premium_LRS | `os_disk.storage_account_type` |

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_vm_id` | Virtual machine resource ID |
| `public_vm_name` | Virtual machine name |
| `public_vm_private_ip` | Private IP address |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **SSH-only access:** Password authentication is always disabled. The `admin_ssh_public_key` variable is required. This is a deliberate security decision with no override.
- **No private endpoint:** VMs don't use private endpoints. Network isolation is achieved through subnet placement and NSG rules.
- **B-series VMs:** B-series (burstable) VMs don't support accelerated networking. The module doesn't set `accelerated_networking_enabled` to avoid deployment failures with small VM sizes.
- **Data disk zones:** Data disks are created in the same availability zone as the VM. This is required -- cross-zone disk attachment is not supported.
- **Custom data:** Must be base64-encoded by the consumer. Typically used for cloud-init scripts. Mark as sensitive in your calling module.
- **Boot diagnostics:** When enabled without a storage URI, Azure uses managed storage (recommended). Set `boot_diagnostics_storage_uri` only if you need a specific storage account.
