# Module: virtual-machine

**Priority:** P3
**Status:** Complete
**Target Version:** v1.0.0

## What It Creates

- `azurerm_public_ip` — Public IP (when `enable_public_ip = true`)
- `azurerm_network_interface` — Network interface
- `azurerm_linux_virtual_machine` — Linux VM
- `azurerm_managed_disk` — Data disks (for_each)
- `azurerm_virtual_machine_data_disk_attachment` — Disk attachments (for_each)

## v1.0.0 Scope

An Azure Linux Virtual Machine with network interface, optional public IP, data disk management, and managed identity support.

### In Scope

- Linux VM with SSH key authentication (password auth always disabled)
- Network interface with configurable IP allocation
- Optional public IP address
- Data disk management with for_each
- Configurable source image (defaults to Ubuntu 22.04 LTS Gen2)
- System and user-assigned managed identity support
- Boot diagnostics support
- Availability zone support

### Out of Scope (Deferred)

- Windows VM support
- VM extensions
- VM scale sets
- Proximity placement groups
- Dedicated hosts
- Accelerated networking (varies by VM size)
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
| `size` | string | Yes | — | VM size (e.g., Standard_B1s) |
| `subnet_id` | string | Yes | — | Subnet ID for the network interface |
| `admin_username` | string | Yes | — | Admin username |
| `admin_ssh_public_key` | string | Yes | — | SSH public key for authentication |
| `source_image_reference` | object | No | Ubuntu 22.04 LTS Gen2 | Source image reference |
| `os_disk` | object | No | Premium_LRS, ReadWrite | OS disk configuration |
| `data_disks` | map(object) | No | `{}` | Map of data disks |
| `zone` | string | No | `null` | Availability zone |
| `custom_data` | string | No | `null` | Base64-encoded custom data (sensitive) |
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

- **SSH-only access:** Password authentication is always disabled. No override variable.
- **B-series VMs:** Don't support accelerated networking. The module doesn't set it.
- **Data disk zones:** Data disks share the VM's availability zone.
- **Custom data:** Must be base64-encoded by the consumer.
- **Identity type computation:** Uses the same pattern as function-app module.
