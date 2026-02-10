# route-table

**Complexity:** Low

Creates an Azure Route Table with configurable routes managed as separate resources.

## Usage

```hcl
module "route_table" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//route-table?ref=route-table/v1.0.0"

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

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **Subnet association:** This module does not associate the route table with subnets. Use `azurerm_subnet_route_table_association` resources separately or configure `route_table_id` on subnets in the virtual-network module.
- **Separate route resources:** Routes are created as `azurerm_route` resources rather than inline blocks to prevent lifecycle issues when adding or removing routes.
- **Virtual Appliance routes:** When `next_hop_type = "VirtualAppliance"`, `next_hop_in_ip_address` is required (typically a firewall's private IP).
