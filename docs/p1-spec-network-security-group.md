# Module: network-security-group

**Priority:** P1  
**Status:** Not Started  
**Target Version:** v1.0.0

## What It Creates

- `azurerm_network_security_group` — Azure Network Security Group
- `azurerm_network_security_rule` — One rule per entry in the `security_rules` variable

## v1.0.0 Scope

A network security group with configurable security rules. Rules are managed via a map variable to allow flexible rule definition. The NSG itself does not associate with subnets — that is done by the consumer (via the `virtual-network` module's `network_security_group_id` subnet property or directly via `azurerm_subnet_network_security_group_association`).

### In Scope

- NSG creation
- Security rules via map variable
- Support for inbound and outbound rules
- Support for service tags, CIDR ranges, and application security group references

### Out of Scope (Deferred)

- Subnet association (consumer responsibility)
- NIC association (consumer responsibility)
- Flow logs (use the standalone `diagnostic-settings` module or configure separately)
- Default deny-all rules (Azure provides implicit deny — explicit rules only when needed)

## Feature Flags

No feature flags for v1.0.0. Rules are controlled entirely via the `security_rules` variable.

## Private Endpoint Support

Not applicable. NSGs do not have private endpoints.

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `security_rules` | map(object) | No | `{}` | Map of security rules to create (see below) |

### Security Rules Variable Structure

```hcl
variable "security_rules" {
  type = map(object({
    priority                     = number
    direction                    = string  # Inbound, Outbound
    access                       = string  # Allow, Deny
    protocol                     = string  # Tcp, Udp, Icmp, Esp, Ah, *
    source_port_range            = optional(string, "*")
    destination_port_range       = optional(string, null)
    destination_port_ranges      = optional(list(string), null)
    source_address_prefix        = optional(string, null)
    source_address_prefixes      = optional(list(string), null)
    destination_address_prefix   = optional(string, null)
    destination_address_prefixes = optional(list(string), null)
    description                  = optional(string, "")
  }))
  default     = {}
  description = "Map of security rules. Key is used as the rule name."
}
```

### Example Usage

```hcl
security_rules = {
  allow-https-inbound = {
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  allow-ssh-inbound = {
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
    description                = "Allow SSH from internal network"
  }
}
```

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `public_nsg_id` | NSG resource ID (for cross-project consumption) |

## Notes

- **Rules as separate resources:** Security rules are created as `azurerm_network_security_rule` resources rather than inline in the NSG. This avoids the lifecycle issue where inline rules are destroyed and recreated when the rule set changes.
- **Map key = rule name:** Using a map avoids list-ordering issues. Adding or removing a rule does not affect other rules.
- **No default rules:** The module does not create any default security rules. Azure provides implicit default rules (deny all inbound from internet, allow all outbound to internet, allow inbound from vnet/load balancer). Consumers add explicit rules as needed.
