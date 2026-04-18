# virtual-network

**Complexity:** Low

Creates an Azure Virtual Network with configurable subnets managed via a map variable.

## Usage

```hcl
module "virtual_network" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/virtual-network?ref=virtual-network/v1.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "vnet-payments-dev-weu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-app = {
      address_prefixes                  = ["10.0.1.0/24"]
      service_endpoints                 = ["Microsoft.Storage", "Microsoft.KeyVault"]
      private_endpoint_network_policies = "Disabled"
    }
    snet-data = {
      address_prefixes = ["10.0.2.0/24"]
    }
  }

  subnet_nsg_associations = {
    snet-app = azurerm_network_security_group.app.id
  }

  tags = local.common_tags
}
```

## Features

- Virtual network with configurable address space
- Subnets via map variable (no list ordering issues)
- NSG association per subnet (`subnet_nsg_associations`)
- Route table association per subnet (`subnet_route_table_associations`)
- Service endpoints per subnet
- Subnet delegation support
- Private endpoint network policies configuration

## Security Defaults

This module does not apply security defaults at the network level. Security is implemented through:

- Network Security Groups (created separately, associated via `subnet_nsg_associations`)
- Route tables (created separately, associated via `subnet_route_table_associations`)

## Subnet Configuration

Each subnet in the `subnets` map supports:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `address_prefixes` | list(string) | Required | Subnet address prefixes |
| `service_endpoints` | list(string) | `[]` | Service endpoints to enable |
| `private_endpoint_network_policies` | string | `"Enabled"` | Set to `"Disabled"` for PE subnets |
| `private_link_service_network_policies_enabled` | bool | `false` | Enable for private link services |
| `delegation` | object | `null` | Service delegation configuration |

## NSG and Route Table Associations

NSG and route table associations are managed via separate variables to avoid Terraform `for_each` unknown-value issues when creating resources in the same configuration:

```hcl
subnet_nsg_associations = {
  snet-app  = azurerm_network_security_group.app.id
  snet-data = azurerm_network_security_group.data.id
}

subnet_route_table_associations = {
  snet-data = azurerm_route_table.data.id
}
```

Keys must match subnet names defined in the `subnets` variable.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_vnet_id` | Virtual network resource ID |
| `public_vnet_name` | Virtual network name |
| `public_subnet_ids` | Map of subnet name to subnet ID |

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
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | Address space for the virtual network (e.g., ["10.0.0.0/16"]) | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Virtual network name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_subnet_nsg_associations"></a> [subnet\_nsg\_associations](#input\_subnet\_nsg\_associations) | Map of subnet name to NSG resource ID. Keys must match keys in the subnets variable. | `map(string)` | `{}` | no |
| <a name="input_subnet_route_table_associations"></a> [subnet\_route\_table\_associations](#input\_subnet\_route\_table\_associations) | Map of subnet name to route table resource ID. Keys must match keys in the subnets variable. | `map(string)` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnets. Key is used as the subnet name. | <pre>map(object({<br/>    address_prefixes                              = list(string)<br/>    service_endpoints                             = optional(list(string), [])<br/>    private_endpoint_network_policies             = optional(string, "Enabled")<br/>    private_link_service_network_policies_enabled = optional(bool, false)<br/>    delegation = optional(object({<br/>      name = string<br/>      service_delegation = object({<br/>        name    = string<br/>        actions = optional(list(string), [])<br/>      })<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_space"></a> [address\_space](#output\_address\_space) | Virtual network address space |
| <a name="output_id"></a> [id](#output\_id) | Virtual network resource ID |
| <a name="output_name"></a> [name](#output\_name) | Virtual network name |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Map of subnet name to subnet ID (for cross-project consumption) |
| <a name="output_public_vnet_id"></a> [public\_vnet\_id](#output\_public\_vnet\_id) | Virtual network resource ID (for cross-project consumption) |
| <a name="output_public_vnet_name"></a> [public\_vnet\_name](#output\_public\_vnet\_name) | Virtual network name (for cross-project consumption) |
| <a name="output_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#output\_subnet\_address\_prefixes) | Map of subnet name to address prefixes |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet name to subnet ID |
<!-- END_TF_DOCS -->

## Notes

- **Subnets as separate resources:** Subnets are managed as separate `azurerm_subnet` resources with `for_each` for clean lifecycle management. NSG and route table associations use separate association resources to avoid inline conflicts.
- **No GatewaySubnet validation:** The module does not validate special subnet names. Use correct names for Azure-reserved subnets (GatewaySubnet, AzureFirewallSubnet, etc.).
- **Private endpoints:** Set `private_endpoint_network_policies = "Disabled"` on subnets that will host private endpoints.
