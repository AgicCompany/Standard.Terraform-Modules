# Module: virtual-network

**Priority:** P0
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_virtual_network` — Azure Virtual Network
- `azurerm_subnet` — One subnet per entry in the `subnets` variable

## v1.0.0 Scope

A virtual network with configurable subnets managed inline via a map variable. Subnets support optional NSG and route table associations. The module outputs subnet IDs for consumers to use when deploying resources or private endpoints.

### In Scope

- VNet creation with configurable address space
- Subnets via map variable (inline, not separate resources)
- NSG association per subnet (via `network_security_group_id`)
- Route table association per subnet (via `route_table_id`)
- Service endpoint configuration per subnet
- Subnet delegation configuration per subnet

### Out of Scope (Deferred)

- VNet peering (consumer responsibility or future module)
- DNS settings (use Azure-provided DNS by default)
- DDoS protection plan association
- Standalone subnet module (extract later if demand materializes)

## Feature Flags

No feature flags for v1.0.0. Subnet configuration is controlled entirely via the `subnets` variable.

## Private Endpoint Support

Not applicable. VNets do not have private endpoints. However, VNets provide the subnets where private endpoints are deployed.

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `address_space` | list(string) | Yes | — | Address space for the virtual network (e.g., `["10.0.0.0/16"]`) |
| `subnets` | map(object) | No | `{}` | Map of subnets to create (see below) |

### Subnets Variable Structure

```hcl
variable "subnets" {
  type = map(object({
    address_prefixes                              = list(string)
    network_security_group_id                     = optional(string, null)
    route_table_id                                = optional(string, null)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, false)
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }), null)
  }))
  default     = {}
  description = "Map of subnets. Key is used as the subnet name."
}
```

### Example Usage

```hcl
subnets = {
  snet-app = {
    address_prefixes              = ["10.0.1.0/24"]
    network_security_group_id     = azurerm_network_security_group.app.id
    service_endpoints             = ["Microsoft.Storage", "Microsoft.KeyVault"]
    private_endpoint_network_policies = "Disabled"
  }
  snet-db = {
    address_prefixes          = ["10.0.2.0/24"]
    network_security_group_id = azurerm_network_security_group.db.id
    route_table_id            = azurerm_route_table.db.id
  }
  snet-appservice = {
    address_prefixes = ["10.0.3.0/24"]
    delegation = {
      name = "appservice"
      service_delegation = {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}
```

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `address_space` | VNet address space |
| `subnet_ids` | Map of subnet name to subnet ID |
| `subnet_address_prefixes` | Map of subnet name to address prefixes |
| `public_vnet_id` | VNet resource ID (for cross-project consumption) |
| `public_vnet_name` | VNet name (for cross-project consumption) |
| `public_subnet_ids` | Map of subnet name to subnet ID (for cross-project consumption) |

## Notes

- **Subnets inline vs separate:** Subnets are managed inline rather than as separate `azurerm_subnet` resources. This is a deliberate simplification for v1.0.0. The tradeoff is that adding/removing subnets may cause recreation of other subnets if Terraform's state gets confused. Using a map (keyed by name) minimizes this risk.
- **No GatewaySubnet or AzureFirewallSubnet validation:** The module does not validate special subnet names. Consumers are responsible for using correct names when required by Azure services.
- **NSG/Route Table association:** The module uses `network_security_group_id` and `route_table_id` properties on the subnet rather than creating separate association resources. This is simpler and avoids circular dependency issues.
- **Private endpoint network policies:** The `private_endpoint_network_policies` setting defaults to `"Enabled"` (Azure default). Set to `"Disabled"` on subnets that will host private endpoints. Note: in older provider versions this was a boolean, but AzureRM 4.x uses a string enum.
