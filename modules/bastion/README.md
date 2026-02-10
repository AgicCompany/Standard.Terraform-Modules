# bastion

**Complexity:** Low

Creates an Azure Bastion host with automatic public IP provisioning, providing secure RDP/SSH access to virtual machines without exposing them to the internet.

## Usage

```hcl
module "bastion" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//bastion?ref=bastion/v1.0.0"

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

- Basic, Standard, and Developer SKU support
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
<!-- END_TF_DOCS -->

## Notes

- **Provisioning time:** Azure Bastion typically takes 5-10 minutes to provision.
- **Standard SKU features are gated:** Features like file copy, IP connect, shareable links, and tunneling are only available with Standard SKU. When using Basic SKU, these settings are automatically set to their defaults.
- **Subnet requirement:** The subnet must be named exactly `AzureBastionSubnet`. This module does not create the subnet; the consumer must provide it.
