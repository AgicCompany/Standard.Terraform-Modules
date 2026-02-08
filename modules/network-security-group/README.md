# network-security-group

**Complexity:** Simple

Creates an Azure Network Security Group with configurable security rules managed as separate resources.

## Usage

```hcl
module "nsg" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//network-security-group?ref=network-security-group/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "nsg-app-dev-weu-001"

  security_rules = {
    allow-https-inbound = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  tags = local.common_tags
}
```

## Features

- NSG creation with map-based security rules
- Rules managed as separate `azurerm_network_security_rule` resources (avoids lifecycle issues with inline rules)
- Supports service tags, CIDR ranges, and application security group references
- Flexible port and address configuration (single or multiple)

## Security Defaults

This module creates an empty NSG by default (no rules). Azure provides implicit default rules:

| Default Rule | Priority | Direction | Access |
|-------------|----------|-----------|--------|
| AllowVNetInBound | 65000 | Inbound | Allow |
| AllowAzureLoadBalancerInBound | 65001 | Inbound | Allow |
| DenyAllInBound | 65500 | Inbound | Deny |
| AllowVNetOutBound | 65000 | Outbound | Allow |
| AllowInternetOutBound | 65001 | Outbound | Allow |
| DenyAllOutBound | 65500 | Outbound | Deny |

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **Separate rule resources:** Rules are created as `azurerm_network_security_rule` resources rather than inline blocks to prevent lifecycle issues when adding or removing rules.
- **Subnet association:** This module does not associate the NSG with subnets. Use the virtual-network module's `network_security_group_id` parameter or create `azurerm_subnet_network_security_group_association` resources separately.
- **Rule priorities:** Must be unique per direction. Use increments of 10 or 100 to allow future insertions.
