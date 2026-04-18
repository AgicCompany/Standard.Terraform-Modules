# static-web-app

**Complexity:** Low

Creates an Azure Static Web App with configurable SKU, app settings, and preview environments.

## Usage

```hcl
module "static_web_app" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/static-web-app?ref=static-web-app/v2.0.0"

  resource_group_name = "rg-stapp-dev-weu-001"
  location            = "westeurope"
  name                = "stapp-myapp-dev-weu-001"

  # PE requires Standard SKU, subnet, and DNS zone
  sku_tier            = "Standard"
  sku_size            = "Standard"
  subnet_id           = module.vnet.subnet_ids["snet-pe"]
  private_dns_zone_id = module.dns.zone_ids["privatelink.azurestaticapps.net"]

  tags = local.common_tags
}
```

## Features

- Static Web App with Free or Standard SKU
- Private endpoint support (Standard SKU required)
- Public network access control
- Application settings (environment variables)
- Preview environments for pull requests
- Configuration file changes control

## Security Defaults

Static Web Apps are secure by default:

| Setting | Default | Notes |
|---------|---------|-------|
| HTTPS | Enforced | Always HTTPS, managed by Azure |
| Certificates | Managed | Azure manages TLS certificates |
| Private endpoint | Disabled | `enable_private_endpoint` (requires Standard SKU) |
| Public access | Enabled | `enable_public_access` (disabling requires Standard SKU) |
| Preview environments | Enabled | `preview_environments_enabled` |
| Config file changes | Enabled | `configuration_file_changes_enabled` |

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_static_web_app_id` | Static Web App resource ID (for cross-project consumption) |
| `public_default_host_name` | Default hostname (for cross-project consumption) |

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.60.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_static_web_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/static_web_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Application settings (environment variables) | `map(string)` | `{}` | no |
| <a name="input_configuration_file_changes_enabled"></a> [configuration\_file\_changes\_enabled](#input\_configuration\_file\_changes\_enabled) | Allow configuration file changes | `bool` | `true` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for the Static Web App. Requires Standard SKU. | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access. Disabling requires Standard SKU. Set to true when not using a private endpoint. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Static Web App name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_preview_environments_enabled"></a> [preview\_environments\_enabled](#input\_preview\_environments\_enabled) | Enable preview environments for pull requests | `bool` | `true` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.azurestaticapps.net. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Override the private endpoint resource name. Defaults to pep-{name}. | `string` | `null` | no |
| <a name="input_private_endpoint_nic_name"></a> [private\_endpoint\_nic\_name](#input\_private\_endpoint\_nic\_name) | Override the PE network interface name. Defaults to pep-{name}-nic. | `string` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Override the private service connection name. Defaults to psc-{name}. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku_size"></a> [sku\_size](#input\_sku\_size) | SKU size for the Static Web App. Must match sku\_tier. | `string` | `"Standard"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU tier for the Static Web App. Standard enables private endpoints and disabling public access. | `string` | `"Standard"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_host_name"></a> [default\_host\_name](#output\_default\_host\_name) | Default hostname of the Static Web App |
| <a name="output_id"></a> [id](#output\_id) | Static Web App resource ID |
| <a name="output_name"></a> [name](#output\_name) | Static Web App name |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_default_host_name"></a> [public\_default\_host\_name](#output\_public\_default\_host\_name) | Default hostname (for cross-project consumption) |
| <a name="output_public_static_web_app_id"></a> [public\_static\_web\_app\_id](#output\_public\_static\_web\_app\_id) | Static Web App resource ID (for cross-project consumption) |
<!-- END_TF_DOCS -->

## Notes

- **GitHub/Azure DevOps integration:** CI/CD pipeline integration is handled outside this module using the `api_key` output.
- **Private endpoints:** Require Standard SKU. The module enforces this with a lifecycle precondition. The consumer provides the PE subnet and private DNS zone (`privatelink.azurestaticapps.net`).
- **Limited region availability:** Static Web Apps are available in limited regions (westus2, centralus, eastus2, westeurope, eastasia, eastasiaapac).
