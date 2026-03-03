# route-table

**Complexity:** Low

Creates an Azure Route Table with configurable routes managed as separate resources.

## Usage

```hcl
module "route_table" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//route-table?ref=route-table/v1.1.0"

  resource_group_name = "rg-example-dev-weu-001"
  location            = "westeurope"
  name                = "rt-example-dev-weu-001"

  routes = {
    to-firewall = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.1.4"
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Features

- Route table creation with map-based routes
- Routes managed as separate `azurerm_route` resources (avoids lifecycle issues with inline routes)
- Configurable BGP route propagation
- Supports all next hop types: VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance, None

## Security Defaults

BGP route propagation is enabled by default. Set `disable_bgp_route_propagation = true` for subnets that should not learn routes from on-premises networks (e.g., DMZ subnets).

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_route_table_id` | Route table resource ID (for cross-project consumption) |

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
| [azurerm_route.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_disable_bgp_route_propagation"></a> [disable\_bgp\_route\_propagation](#input\_disable\_bgp\_route\_propagation) | Disable BGP route propagation | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Route table name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_routes"></a> [routes](#input\_routes) | Map of routes. Key is used as the route name. | <pre>map(object({<br/>    address_prefix         = string<br/>    next_hop_type          = string<br/>    next_hop_in_ip_address = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Route table resource ID |
| <a name="output_name"></a> [name](#output\_name) | Route table name |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id) | Route table resource ID (for cross-project consumption) |
| <a name="output_route_ids"></a> [route\_ids](#output\_route\_ids) | Map of route names to route resource IDs |
<!-- END_TF_DOCS -->

## Notes

- **Subnet association:** This module does not associate the route table with subnets. Use `azurerm_subnet_route_table_association` resources separately or configure `route_table_id` on subnets in the virtual-network module.
- **Separate route resources:** Routes are created as `azurerm_route` resources rather than inline blocks to prevent lifecycle issues when adding or removing routes.
- **Valid `next_hop_type` values:** `Internet`, `VirtualAppliance`, `VnetLocal`, `VirtualNetworkGateway`, `None`. Case-sensitive.
- **Virtual Appliance routes:** When `next_hop_type = "VirtualAppliance"`, `next_hop_in_ip_address` is required (typically a firewall's private IP).
