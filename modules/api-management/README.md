# api-management

**Complexity:** High

Creates an Azure API Management service with secure defaults, VNet integration, multi-region support, and optional private endpoint.

## Usage

```hcl
module "apim" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/api-management?ref=api-management/v1.0.0"

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
| [azurerm_api_management.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_locations"></a> [additional\_locations](#input\_additional\_locations) | Additional deployment locations for multi-region (Premium SKU only) | <pre>list(object({<br/>    location                  = string<br/>    zones                     = optional(list(string))<br/>    virtual_network_subnet_id = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled) | Enable client certificate authentication | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for this API Management service | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access | `bool` | `false` | no |
| <a name="input_gateway_disabled"></a> [gateway\_disabled](#input\_gateway\_disabled) | Disable gateway in the main region (for multi-region with External/Internal VNet) | `bool` | `false` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned identity IDs | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Type of managed identity | `string` | `"SystemAssigned"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_min_api_version"></a> [min\_api\_version](#input\_min\_api\_version) | Minimum API version to enforce | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | API Management service name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_notification_sender_email"></a> [notification\_sender\_email](#input\_notification\_sender\_email) | Email address for sending notifications | `string` | `null` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.azure-api.net. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Override the private endpoint resource name. Defaults to pep-{name}. | `string` | `null` | no |
| <a name="input_private_endpoint_nic_name"></a> [private\_endpoint\_nic\_name](#input\_private\_endpoint\_nic\_name) | Override the PE network interface name. Defaults to pep-{name}-nic. | `string` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Override the private service connection name. Defaults to psc-{name}. | `string` | `null` | no |
| <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email) | Publisher email (for notifications) | `string` | n/a | yes |
| <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name) | Publisher name (shown in developer portal) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | SKU in format {tier}\_{capacity} | `string` | `"Developer_1"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id) | Subnet ID for VNet integration (required when virtual\_network\_type is External or Internal) | `string` | `null` | no |
| <a name="input_virtual_network_type"></a> [virtual\_network\_type](#input\_virtual\_network\_type) | Type of VNet integration | `string` | `"None"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Availability zones (Premium SKU only) | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_developer_portal_url"></a> [developer\_portal\_url](#output\_developer\_portal\_url) | Developer portal URL of the API Management service |
| <a name="output_gateway_url"></a> [gateway\_url](#output\_gateway\_url) | Gateway URL of the API Management service |
| <a name="output_id"></a> [id](#output\_id) | API Management service resource ID |
| <a name="output_management_api_url"></a> [management\_api\_url](#output\_management\_api\_url) | Management API URL of the API Management service |
| <a name="output_name"></a> [name](#output\_name) | API Management service name |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID (when enabled) |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_apim_gateway_url"></a> [public\_apim\_gateway\_url](#output\_public\_apim\_gateway\_url) | Gateway URL (for cross-project consumption) |
| <a name="output_public_apim_id"></a> [public\_apim\_id](#output\_public\_apim\_id) | API Management service ID (for cross-project consumption) |
| <a name="output_public_apim_name"></a> [public\_apim\_name](#output\_public\_apim\_name) | API Management service name (for cross-project consumption) |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | Public IP addresses of the API Management service |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned managed identity tenant ID (when enabled) |
<!-- END_TF_DOCS -->

## Notes

- **Provisioning time:** Developer SKU takes 30-45 minutes to provision. Premium SKU can take longer.
- **Consumption SKU:** Has limited features compared to dedicated SKUs. Does not support VNet integration, private endpoints, or availability zones.
- **Premium required:** Multi-region deployment (`additional_locations`) and availability zones (`zones`) require the Premium SKU.
- **APIs/products/subscriptions:** This module creates the APIM infrastructure only. APIs, products, subscriptions, and policies are managed separately by API teams.
- **VNet integration:** When using External or Internal `virtual_network_type`, you must provide `virtual_network_subnet_id`. The subnet requires the `Microsoft.ApiManagement/service` service delegation.
- **Naming:** CAF prefix for API Management is `apim`. Example: `apim-payments-dev-weu-001`.
