# windows-virtual-machine

**Complexity:** Medium

Creates an Azure Windows Virtual Machine with network interface, optional public IP, and data disk management.

## Usage

```hcl
module "virtual_machine" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//windows-virtual-machine?ref=windows-virtual-machine/v1.0.0"

  resource_group_name = "rg-compute-dev-weu-001"
  location            = "westeurope"
  name                = "vm-app-dev-weu-001"
  size                = "Standard_B2s"
  subnet_id           = module.vnet.subnet_ids["snet-compute"]
  admin_username      = "azureadmin"
  admin_password      = var.admin_password

  tags = local.common_tags
}
```

## Features

- Windows VM with password authentication
- Network interface with configurable IP allocation
- Optional public IP address
- Data disk management with for_each
- Configurable source image (defaults to Windows Server 2022 Datacenter Gen2)
- System and user-assigned managed identity support
- Boot diagnostics support
- Availability zone support
- Azure Hybrid Benefit support
- Timezone configuration
- Automatic computer name truncation (15-character Windows limit)

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Public IP | None | `enable_public_ip` |
| OS disk type | Premium_LRS | `os_disk.storage_account_type` |
| Admin password | Required (sensitive) | `admin_password` |

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

- **Password authentication:** Windows VMs use password authentication. The `admin_password` must meet Azure complexity requirements (12+ characters, uppercase, lowercase, number, special character).
- **Computer name limit:** Windows computer names are limited to 15 characters. The module automatically truncates `var.name` to 15 characters. Override with `var.computer_name` if needed.
- **No private endpoint:** VMs don't use private endpoints. Network isolation is achieved through subnet placement and NSG rules.
- **Azure Hybrid Benefit:** Set `license_type = "Windows_Server"` to use existing Windows Server licenses and reduce costs.
- **Data disk zones:** Data disks are created in the same availability zone as the VM. This is required -- cross-zone disk attachment is not supported.
- **Custom data:** Must be base64-encoded by the consumer. Typically used for PowerShell scripts via CustomScriptExtension.
- **Boot diagnostics:** When enabled without a storage URI, Azure uses managed storage (recommended). Set `boot_diagnostics_storage_uri` only if you need a specific storage account.
