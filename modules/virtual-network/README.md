# virtual-network

**Complexity:** Low

Creates an Azure Virtual Network with configurable subnets managed via a map variable.

## Usage

```hcl
module "virtual_network" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//virtual-network?ref=virtual-network/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "vnet-payments-dev-weu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-app = {
      address_prefixes              = ["10.0.1.0/24"]
      network_security_group_id     = azurerm_network_security_group.app.id
      service_endpoints             = ["Microsoft.Storage", "Microsoft.KeyVault"]
      private_endpoint_network_policies = "Disabled"
    }
    snet-data = {
      address_prefixes = ["10.0.2.0/24"]
    }
  }

  tags = local.common_tags
}
```

## Features

- Virtual network with configurable address space
- Subnets via map variable (no list ordering issues)
- NSG association per subnet (`network_security_group_id`)
- Route table association per subnet (`route_table_id`)
- Service endpoints per subnet
- Subnet delegation support
- Private endpoint network policies configuration

## Security Defaults

This module does not apply security defaults at the network level. Security is implemented through:

- Network Security Groups (created separately, associated via `network_security_group_id`)
- Route tables (created separately, associated via `route_table_id`)

## Subnet Configuration

Each subnet in the `subnets` map supports:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `address_prefixes` | list(string) | Required | Subnet address prefixes |
| `network_security_group_id` | string | `null` | NSG to associate |
| `route_table_id` | string | `null` | Route table to associate |
| `service_endpoints` | list(string) | `[]` | Service endpoints to enable |
| `private_endpoint_network_policies` | string | `"Enabled"` | Set to `"Disabled"` for PE subnets |
| `private_link_service_network_policies_enabled` | bool | `false` | Enable for private link services |
| `delegation` | object | `null` | Service delegation configuration |

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_vnet_id` | Virtual network resource ID |
| `public_vnet_name` | Virtual network name |
| `public_subnet_ids` | Map of subnet name to subnet ID |

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **Subnets are inline:** Subnets are managed as part of the module, not as separate resources. Adding/removing subnets should work cleanly due to map-based addressing.
- **No GatewaySubnet validation:** The module does not validate special subnet names. Use correct names for Azure-reserved subnets (GatewaySubnet, AzureFirewallSubnet, etc.).
- **Private endpoints:** Set `private_endpoint_network_policies = "Disabled"` on subnets that will host private endpoints.
