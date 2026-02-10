# api-management

**Complexity:** High

Creates an Azure API Management service with secure defaults, VNet integration, multi-region support, and optional private endpoint.

## Usage

```hcl
module "apim" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//api-management?ref=api-management/v1.0.0"

  resource_group_name = "rg-apim-dev-weu-001"
  location            = "westeurope"
  name                = "apim-payments-dev-weu-001"
  publisher_name      = "Contoso"
  publisher_email     = "apim@contoso.com"

  sku_name = "Developer_1"

  subnet_id           = module.vnet.subnet_ids["pe-subnet"]
  private_dns_zone_id = module.dns_apim.id

  tags = local.common_tags
}
```

## Features

- Developer, Basic, Standard, Premium, and Consumption SKU support
- VNet integration (External and Internal modes)
- Multi-region deployment (Premium SKU)
- Availability zones (Premium SKU)
- System-assigned and user-assigned managed identity support
- Client certificate authentication
- Private endpoint for `Gateway` subresource
- Configurable notification sender email and minimum API version

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Public access | Disabled | `enable_public_access` |
| Private endpoint | Enabled | `enable_private_endpoint` |
| Identity | SystemAssigned | `identity_type` |
| Client certificates | Disabled | `client_certificate_enabled` |

## Private Endpoint

When `enable_private_endpoint = true` (default), the following inputs are required:

| Variable | Description |
|----------|-------------|
| `subnet_id` | Subnet ID for the private endpoint |
| `private_dns_zone_id` | Private DNS zone ID for `privatelink.azure-api.net` |

The module creates the private endpoint and configures DNS zone group registration.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_apim_id` | API Management service resource ID |
| `public_apim_name` | API Management service name |
| `public_apim_gateway_url` | Gateway URL |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Notes

- **Provisioning time:** Developer SKU takes 30-45 minutes to provision. Premium SKU can take longer.
- **Consumption SKU:** Has limited features compared to dedicated SKUs. Does not support VNet integration, private endpoints, or availability zones.
- **Premium required:** Multi-region deployment (`additional_locations`) and availability zones (`zones`) require the Premium SKU.
- **APIs/products/subscriptions:** This module creates the APIM infrastructure only. APIs, products, subscriptions, and policies are managed separately by API teams.
- **VNet integration:** When using External or Internal `virtual_network_type`, you must provide `virtual_network_subnet_id`. The subnet requires the `Microsoft.ApiManagement/service` service delegation.
- **Naming:** CAF prefix for API Management is `apim`. Example: `apim-payments-dev-weu-001`.
