# linux-virtual-machine

**Complexity:** Medium

Creates an Azure Linux Virtual Machine with network interface, optional public IP, and data disk management.

## Usage

```hcl
module "virtual_machine" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/linux-virtual-machine?ref=linux-virtual-machine/v1.1.0"

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

- Linux VM with SSH key authentication (default) or optional password auth
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
| Password auth | Disabled | `enable_password_auth` |
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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.60.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine_data_disk_attachment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password. Required when enable\_password\_auth = true. | `string` | `null` | no |
| <a name="input_admin_ssh_public_key"></a> [admin\_ssh\_public\_key](#input\_admin\_ssh\_public\_key) | SSH public key for admin user authentication. Required when enable\_password\_auth = false. | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Admin username for the VM | `string` | n/a | yes |
| <a name="input_boot_diagnostics_storage_uri"></a> [boot\_diagnostics\_storage\_uri](#input\_boot\_diagnostics\_storage\_uri) | Storage account URI for boot diagnostics. If null with boot diagnostics enabled, uses managed storage. | `string` | `null` | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | Base64-encoded custom data (cloud-init) to pass to the VM | `string` | `null` | no |
| <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks) | Map of data disks to attach. Key is used as disk name suffix. | <pre>map(object({<br/>    lun                  = number<br/>    disk_size_gb         = number<br/>    storage_account_type = optional(string, "Premium_LRS")<br/>    caching              = optional(string, "ReadOnly")<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_boot_diagnostics"></a> [enable\_boot\_diagnostics](#input\_enable\_boot\_diagnostics) | Enable boot diagnostics | `bool` | `false` | no |
| <a name="input_enable_password_auth"></a> [enable\_password\_auth](#input\_enable\_password\_auth) | Enable password authentication (default: SSH-only for security) | `bool` | `false` | no |
| <a name="input_enable_public_ip"></a> [enable\_public\_ip](#input\_enable\_public\_ip) | Create and attach a public IP address | `bool` | `false` | no |
| <a name="input_enable_system_assigned_identity"></a> [enable\_system\_assigned\_identity](#input\_enable\_system\_assigned\_identity) | Enable system-assigned managed identity | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Virtual machine name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk) | OS disk configuration | <pre>object({<br/>    caching              = optional(string, "ReadWrite")<br/>    storage_account_type = optional(string, "Premium_LRS")<br/>    disk_size_gb         = optional(number)<br/>  })</pre> | `{}` | no |
| <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address) | Static private IP address. Required when private\_ip\_address\_allocation = Static. | `string` | `null` | no |
| <a name="input_private_ip_address_allocation"></a> [private\_ip\_address\_allocation](#input\_private\_ip\_address\_allocation) | Private IP allocation method: Dynamic or Static | `string` | `"Dynamic"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_size"></a> [size](#input\_size) | VM size (e.g., Standard\_B1s, Standard\_D2s\_v5) | `string` | n/a | yes |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | Source image reference. Defaults to Ubuntu 22.04 LTS Gen2. | <pre>object({<br/>    publisher = string<br/>    offer     = string<br/>    sku       = string<br/>    version   = string<br/>  })</pre> | <pre>{<br/>  "offer": "0001-com-ubuntu-server-jammy",<br/>  "publisher": "Canonical",<br/>  "sku": "22_04-lts-gen2",<br/>  "version": "latest"<br/>}</pre> | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the network interface | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | List of user-assigned managed identity IDs | `list(string)` | `[]` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Availability zone (1, 2, or 3) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Virtual machine resource ID |
| <a name="output_name"></a> [name](#output\_name) | Virtual machine name |
| <a name="output_network_interface_id"></a> [network\_interface\_id](#output\_network\_interface\_id) | Network interface resource ID |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the network interface |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Public IP address (when enabled) |
| <a name="output_public_vm_id"></a> [public\_vm\_id](#output\_public\_vm\_id) | Virtual machine resource ID (for cross-project consumption) |
| <a name="output_public_vm_name"></a> [public\_vm\_name](#output\_public\_vm\_name) | Virtual machine name (for cross-project consumption) |
| <a name="output_public_vm_private_ip"></a> [public\_vm\_private\_ip](#output\_public\_vm\_private\_ip) | Private IP address (for cross-project consumption) |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned managed identity tenant ID (when enabled) |
<!-- END_TF_DOCS -->

## Notes

- **SSH-only by default:** Password authentication is disabled by default. Set `enable_password_auth = true` and provide `admin_password` to enable it. At least one authentication method (SSH key or password) is always required.
- **No private endpoint:** VMs don't use private endpoints. Network isolation is achieved through subnet placement and NSG rules.
- **B-series VMs:** B-series (burstable) VMs don't support accelerated networking. The module doesn't set `accelerated_networking_enabled` to avoid deployment failures with small VM sizes.
- **Data disk zones:** Data disks are created in the same availability zone as the VM. This is required -- cross-zone disk attachment is not supported.
- **Custom data:** Must be base64-encoded by the consumer. Typically used for cloud-init scripts. Mark as sensitive in your calling module.
- **Boot diagnostics:** When enabled without a storage URI, Azure uses managed storage (recommended). Set `boot_diagnostics_storage_uri` only if you need a specific storage account.
