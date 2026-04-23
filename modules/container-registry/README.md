# container-registry

**Complexity:** Medium

Creates an Azure Container Registry with secure defaults and optional private endpoint.

## Usage

```hcl
module "container_registry" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/container-registry?ref=container-registry/v2.0.0"

  resource_group_name = "rg-payments-dev-weu-001"
  location            = "westeurope"
  name                = "crpaymentsdevweu001"

  # Private endpoint (required inputs when enable_private_endpoint = true)
  subnet_id           = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_id = module.private_dns.zone_ids["privatelink.azurecr.io"]

  tags = local.common_tags
}
```

## Features

- Configurable SKU (Basic, Standard, Premium)
- Private endpoint with DNS integration
- Geo-replication support (Premium SKU only)
- System-assigned managed identity (always enabled)
- Admin account toggle (disabled by default)

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Admin account | Disabled | `enable_admin` |
| Public access | Disabled | `enable_public_access` |
| Private endpoint | Enabled | `enable_private_endpoint` |
| SKU | Premium | `sku` |

## Private Endpoint

When `enable_private_endpoint = true` (default), the following inputs are required:

| Variable | Description |
|----------|-------------|
| `subnet_id` | Subnet ID for the private endpoint |
| `private_dns_zone_id` | Private DNS zone ID for `privatelink.azurecr.io` |

The module creates the private endpoint and configures DNS zone group registration.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_acr_id` | Container Registry resource ID |
| `public_acr_name` | Container Registry name |
| `public_acr_login_server` | Login server URL |

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
| [azurerm_container_registry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_admin"></a> [enable\_admin](#input\_enable\_admin) | Enable admin account. Not recommended — use managed identity instead. | `bool` | `false` | no |
| <a name="input_enable_content_trust"></a> [enable\_content\_trust](#input\_enable\_content\_trust) | Enable content trust (image signing). Premium SKU only. | `bool` | `false` | no |
| <a name="input_enable_geo_replication"></a> [enable\_geo\_replication](#input\_enable\_geo\_replication) | Enable geo-replication. Premium SKU only. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for this registry | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access | `bool` | `false` | no |
| <a name="input_georeplications"></a> [georeplications](#input\_georeplications) | Geo-replication locations. Key is used as identifier. Premium SKU only. | <pre>map(object({<br/>    location                  = string<br/>    regional_endpoint_enabled = optional(bool, true)<br/>    zone_redundancy_enabled   = optional(bool, false)<br/>    tags                      = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Container Registry name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.azurecr.io. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Override the private endpoint resource name. Defaults to pep-{name}. | `string` | `null` | no |
| <a name="input_private_endpoint_nic_name"></a> [private\_endpoint\_nic\_name](#input\_private\_endpoint\_nic\_name) | Override the PE network interface name. Defaults to pep-{name}-nic. | `string` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Override the private service connection name. Defaults to psc-{name}. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU tier: Basic, Standard, or Premium | `string` | `"Premium"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Container Registry resource ID |
| <a name="output_login_server"></a> [login\_server](#output\_login\_server) | Login server URL (e.g., myregistry.azurecr.io) |
| <a name="output_name"></a> [name](#output\_name) | Container Registry name |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_acr_id"></a> [public\_acr\_id](#output\_public\_acr\_id) | Container Registry resource ID (for cross-project consumption) |
| <a name="output_public_acr_login_server"></a> [public\_acr\_login\_server](#output\_public\_acr\_login\_server) | Login server URL (for cross-project consumption) |
| <a name="output_public_acr_name"></a> [public\_acr\_name](#output\_public\_acr\_name) | Container Registry name (for cross-project consumption) |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned managed identity tenant ID |
<!-- END_TF_DOCS -->

## Notes

- **SKU defaults to Premium:** Unlike other modules where we default to the cheapest option, ACR defaults to `Premium` because it's the only SKU that supports private endpoints and geo-replication. Since our framework is private-first, a non-Premium SKU with `enable_private_endpoint = true` would fail. If the consumer explicitly sets `enable_private_endpoint = false`, they can use `Basic` or `Standard`.
- **Naming constraint:** ACR names must be globally unique, 5-50 characters, alphanumeric only (no hyphens). Example: `crpaymentsdevweu001`. CAF prefix is `cr`.
- **Admin account:** Disabled by default. The admin account provides a username/password for `docker login`. This is a legacy pattern — modern workloads should use managed identity (`AcrPull` role) or service principals. The `enable_admin` flag exists for edge cases but is not recommended.
- **Managed identity for AKS/Container Apps:** To pull images from ACR, AKS and Container Apps should use managed identity with the `AcrPull` role assigned at the registry scope. This role assignment is the consumer's responsibility, not the module's.
- **Content trust:** Content trust (image signing) is available via the `enable_content_trust` flag. Requires Premium SKU. When enabled, only signed images can be pulled from the registry.
- **Geo-replication:** Only available on Premium SKU. Provides image locality for multi-region deployments. Each replication location incurs additional costs.
