# Module: windows-virtual-machine

**Priority:** P3
**Status:** Released
**Target Version:** v1.0.0

## What It Creates

- `azurerm_public_ip` — Public IP (when `enable_public_ip = true`)
- `azurerm_network_interface` — Network interface
- `azurerm_windows_virtual_machine` — Windows VM
- `azurerm_managed_disk` — Data disks (for_each)
- `azurerm_virtual_machine_data_disk_attachment` — Disk attachments (for_each)

## v1.0.0 Scope

An Azure Windows Virtual Machine with network interface, optional public IP, data disk management, managed identity support, and Azure Hybrid Benefit.

### In Scope

- Windows VM with password authentication
- Network interface with configurable IP allocation
- Optional public IP address
- Data disk management with for_each
- Configurable source image (defaults to Windows Server 2022 Datacenter Gen2)
- System and user-assigned managed identity support
- Boot diagnostics support
- Availability zone support
- Azure Hybrid Benefit (license_type)
- Timezone configuration
- Automatic computer name truncation (15-character Windows limit)

### Out of Scope (Deferred)

- VM extensions
- VM scale sets
- Proximity placement groups
- Dedicated hosts
- Accelerated networking (varies by VM size)
- WinRM configuration
- Diagnostic settings (use the standalone `diagnostic-settings` module)

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_boot_diagnostics` | `false` | Enable boot diagnostics |
| `enable_system_assigned_identity` | `false` | Enable system-assigned managed identity |
| `enable_public_ip` | `false` | Create and attach a public IP address |

## Private Endpoint Support

No private endpoint. VMs don't use private endpoints. Network isolation is achieved through subnet placement and NSG rules.

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `size` | string | Yes | — | VM size (e.g., Standard_B2s) |
| `subnet_id` | string | Yes | — | Subnet ID for the network interface |
| `admin_username` | string | Yes | — | Admin username |
| `admin_password` | string | Yes | — | Admin password (sensitive) |
| `computer_name` | string | No | `null` (auto-truncated from name) | Windows computer name (max 15 chars) |
| `source_image_reference` | object | No | Windows Server 2022 Datacenter Gen2 | Source image reference |
| `os_disk` | object | No | Premium_LRS, ReadWrite | OS disk configuration |
| `data_disks` | map(object) | No | `{}` | Map of data disks |
| `zone` | string | No | `null` | Availability zone |
| `custom_data` | string | No | `null` | Base64-encoded custom data (sensitive) |
| `license_type` | string | No | `null` | Azure Hybrid Benefit: None or Windows_Server |
| `timezone` | string | No | `null` | VM timezone |
| `user_assigned_identity_ids` | list(string) | No | `[]` | User-assigned identity IDs |

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `private_ip_address` | Private IP address of the NIC |
| `network_interface_id` | Network interface resource ID |
| `principal_id` | System-assigned identity principal ID (when enabled) |
| `tenant_id` | System-assigned identity tenant ID (when enabled) |
| `public_ip_address` | Public IP address (when enabled) |
| `public_vm_id` | VM ID (public output) |
| `public_vm_name` | VM name (public output) |
| `public_vm_private_ip` | Private IP (public output) |

## Notes

- **Password authentication:** Windows VMs require a password meeting Azure complexity requirements (12+ characters, uppercase, lowercase, number, special character).
- **Computer name limit:** Windows computer names are limited to 15 characters. The module auto-truncates `var.name`. Override with `var.computer_name`.
- **Azure Hybrid Benefit:** Set `license_type = "Windows_Server"` to use existing licenses and reduce costs.
- **Data disk zones:** Data disks share the VM's availability zone.
- **Custom data:** Must be base64-encoded by the consumer.
- **Identity type computation:** Uses the same pattern as function-app and linux-virtual-machine modules.
