# nat-gateway

**Complexity:** Low

Creates an Azure NAT Gateway with a Standard SKU public IP address for outbound internet connectivity from private subnets.

## Usage

```hcl
module "nat_gateway" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/nat-gateway?ref=nat-gateway/v1.0.0"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "natgw-myapp-dev-weu-001"

  tags = var.tags
}
```

## Features

- NAT Gateway with Standard SKU public IP
- Configurable idle timeout (4-120 minutes)
- Availability zone support
- Automatic public IP creation and association

## Security Defaults

NAT Gateway provides outbound-only internet access. No inbound connections are allowed through the NAT gateway.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_nat_gateway_id` | NAT gateway resource ID (for cross-project consumption) |

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.62.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_idle_timeout_in_minutes"></a> [idle\_timeout\_in\_minutes](#input\_idle\_timeout\_in\_minutes) | Idle timeout in minutes (4-120) | `number` | `4` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | NAT gateway name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU name for the NAT gateway | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Availability zones for the NAT gateway | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | NAT gateway resource ID |
| <a name="output_name"></a> [name](#output\_name) | NAT gateway name |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Public IP address of the NAT gateway |
| <a name="output_public_ip_id"></a> [public\_ip\_id](#output\_public\_ip\_id) | Public IP resource ID |
| <a name="output_public_nat_gateway_id"></a> [public\_nat\_gateway\_id](#output\_public\_nat\_gateway\_id) | NAT gateway resource ID (for cross-project consumption) |
| <a name="output_resource_guid"></a> [resource\_guid](#output\_resource\_guid) | NAT gateway resource GUID |
<!-- END_TF_DOCS -->

## Notes

- **Subnet association:** This module does not associate the NAT gateway with subnets. Use `azurerm_subnet_nat_gateway_association` resources separately or configure `nat_gateway_id` on subnets in the virtual-network module.
- **Public IP:** A Standard SKU static public IP is automatically created and associated. The IP name follows the pattern `pip-{name}`.
- **Zones:** NAT Gateway supports zonal deployment. Specify zones to match the subnets it will serve.
