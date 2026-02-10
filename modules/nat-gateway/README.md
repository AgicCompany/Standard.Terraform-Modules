# nat-gateway

**Complexity:** Low

Creates an Azure NAT Gateway with a Standard SKU public IP address for outbound internet connectivity from private subnets.

## Usage

```hcl
module "nat_gateway" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//nat-gateway?ref=nat-gateway/v1.0.0"

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

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **Subnet association:** This module does not associate the NAT gateway with subnets. Use `azurerm_subnet_nat_gateway_association` resources separately or configure `nat_gateway_id` on subnets in the virtual-network module.
- **Public IP:** A Standard SKU static public IP is automatically created and associated. The IP name follows the pattern `pip-{name}`.
- **Zones:** NAT Gateway supports zonal deployment. Specify zones to match the subnets it will serve.
