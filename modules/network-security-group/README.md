# network-security-group

**Complexity:** Low

Creates an Azure Network Security Group with configurable security rules managed as separate resources.

## Usage

```hcl
module "nsg" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//network-security-group?ref=network-security-group/v1.1.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "nsg-app-dev-weu-001"

  security_rules = {
    allow-https-inbound = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"   # required: one of source_port_range or source_port_ranges
      destination_port_range     = "443" # required: one of destination_port_range or destination_port_ranges
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

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_nsg_id` | Network security group resource ID (for cross-project consumption) |

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Network security group name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | Map of security rules. Key is used as the rule name. | <pre>map(object({<br/>    priority                                   = number<br/>    direction                                  = string<br/>    access                                     = string<br/>    protocol                                   = string<br/>    source_port_range                          = optional(string, null)<br/>    destination_port_range                     = optional(string, null)<br/>    source_port_ranges                         = optional(list(string), null)<br/>    destination_port_ranges                    = optional(list(string), null)<br/>    source_address_prefix                      = optional(string, null)<br/>    destination_address_prefix                 = optional(string, null)<br/>    source_address_prefixes                    = optional(list(string), null)<br/>    destination_address_prefixes               = optional(list(string), null)<br/>    source_application_security_group_ids      = optional(list(string), null)<br/>    destination_application_security_group_ids = optional(list(string), null)<br/>    description                                = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Network security group resource ID |
| <a name="output_name"></a> [name](#output\_name) | Network security group name |
| <a name="output_public_nsg_id"></a> [public\_nsg\_id](#output\_public\_nsg\_id) | Network security group resource ID (for cross-project consumption) |
<!-- END_TF_DOCS -->

## Notes

- **Separate rule resources:** Rules are created as `azurerm_network_security_rule` resources rather than inline blocks to prevent lifecycle issues when adding or removing rules.
- **Subnet association:** This module does not associate the NSG with subnets. Use the virtual-network module's `subnet_nsg_associations` parameter or create `azurerm_subnet_network_security_group_association` resources separately.
- **Port range fields:** Each rule must specify exactly one of `source_port_range` or `source_port_ranges`, and exactly one of `destination_port_range` or `destination_port_ranges`. Neither has a default — both must be explicitly set.
- **Rule priorities:** Must be between 100 and 4096, unique per direction. Use increments of 10 or 100 to allow future insertions.
- **Validated fields:** `direction` (`Inbound`/`Outbound`), `access` (`Allow`/`Deny`), `protocol` (`Tcp`/`Udp`/`Icmp`/`*`) — all case-sensitive Azure API values.
