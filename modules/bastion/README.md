# bastion

**Complexity:** Low

Creates an Azure Bastion host with automatic public IP provisioning, providing secure RDP/SSH access to virtual machines without exposing them to the internet.

## Usage

```hcl
module "bastion" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/bastion?ref=bastion/v1.0.0"

  resource_group_name = "rg-connectivity-dev-weu-001"
  location            = "westeurope"
  name                = "bas-connectivity-dev-weu-001"
  subnet_id           = azurerm_subnet.bastion.id

  sku = "Standard"

  tunneling_enabled  = true
  ip_connect_enabled = true

  tags = local.common_tags
}
```

## Features

- Basic and Standard SKU support
- Standard SKU features: file copy, IP-based connection, shareable links, native client tunneling, scale units
- Automatic public IP provisioning (Standard SKU, static allocation)

## Security Defaults

Bastion provides secure RDP/SSH access without exposing virtual machines to the internet. All connections are brokered through the Azure portal or native client over TLS, eliminating the need for public IPs on VMs.

## Prerequisites

- **AzureBastionSubnet:** The consumer must create a subnet named exactly `AzureBastionSubnet` in the target VNet. Minimum CIDR is /26 for Basic and Standard SKUs.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_bastion_id` | Bastion host resource ID |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_bastion_host.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_copy_paste_enabled"></a> [copy\_paste\_enabled](#input\_copy\_paste\_enabled) | Enable copy/paste functionality | `bool` | `true` | no |
| <a name="input_file_copy_enabled"></a> [file\_copy\_enabled](#input\_file\_copy\_enabled) | Enable file copy (Standard SKU only) | `bool` | `false` | no |
| <a name="input_ip_connect_enabled"></a> [ip\_connect\_enabled](#input\_ip\_connect\_enabled) | Enable IP-based connection (Standard SKU only) | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Azure Bastion host name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_scale_units"></a> [scale\_units](#input\_scale\_units) | Number of scale units (2-50, Standard SKU only) | `number` | `2` | no |
| <a name="input_shareable_link_enabled"></a> [shareable\_link\_enabled](#input\_shareable\_link\_enabled) | Enable shareable links (Standard SKU only) | `bool` | `false` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | Bastion host SKU | `string` | `"Basic"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the AzureBastionSubnet (must be named 'AzureBastionSubnet' with minimum /26 CIDR) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_tunneling_enabled"></a> [tunneling\_enabled](#input\_tunneling\_enabled) | Enable native client tunneling (Standard SKU only) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | FQDN of the Bastion host |
| <a name="output_id"></a> [id](#output\_id) | Bastion host resource ID |
| <a name="output_name"></a> [name](#output\_name) | Bastion host name |
| <a name="output_public_bastion_id"></a> [public\_bastion\_id](#output\_public\_bastion\_id) | Bastion host resource ID (for cross-project consumption) |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Public IP address of the Bastion host |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | Public IP resource ID |
<!-- END_TF_DOCS -->

## Notes

- **Provisioning time:** Azure Bastion typically takes 5-10 minutes to provision.
- **Standard SKU features are gated:** Features like file copy, IP connect, shareable links, and tunneling are only available with Standard SKU. When using Basic SKU, these settings are automatically set to their defaults.
- **Subnet requirement:** The subnet must be named exactly `AzureBastionSubnet`. This module does not create the subnet; the consumer must provide it.
