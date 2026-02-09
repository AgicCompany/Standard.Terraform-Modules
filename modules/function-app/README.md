# function-app

**Complexity:** High

Creates an Azure Linux Function App with secure defaults, application stack configuration, storage account integration, and optional private endpoint.

## Usage

```hcl
module "function_app" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//function-app?ref=function-app/v1.0.0"

  resource_group_name = "rg-func-dev-weu-001"
  location            = "westeurope"
  name                = "func-payments-dev-weu-001"
  service_plan_id     = module.app_plan.id

  storage_account_name       = module.storage.name
  storage_account_access_key = data.azurerm_storage_account.func.primary_access_key

  application_stack = {
    dotnet_version = "8.0"
  }

  application_insights_connection_string = module.app_insights.connection_string

  subnet_id          = module.vnet.subnet_ids["pe-subnet"]
  private_dns_zone_id = module.dns_webapps.id

  tags = local.common_tags
}
```

## Features

- Application stack support (.NET, Node.js, Python, Java, PowerShell, Docker)
- Storage account integration (required by Azure Functions runtime)
- Secure defaults (HTTPS only, minimum TLS 1.2, FTPS disabled, public access disabled)
- Private endpoint for `sites` subresource
- VNet integration for outbound traffic
- Application Insights integration
- System-assigned and user-assigned managed identity support
- Functions runtime version configuration

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| HTTPS only | Enabled | -- (hardcoded) |
| Minimum TLS | 1.2 | -- (hardcoded) |
| FTPS | Disabled | -- (hardcoded) |
| Public access | Disabled | `enable_public_access` |
| Private endpoint | Enabled | `enable_private_endpoint` |
| Application Insights | Enabled | `enable_application_insights` |

## Private Endpoint

When `enable_private_endpoint = true` (default), the following inputs are required:

| Variable | Description |
|----------|-------------|
| `subnet_id` | Subnet ID for the private endpoint |
| `private_dns_zone_id` | Private DNS zone ID for `privatelink.azurewebsites.net` |

The module creates the private endpoint and configures DNS zone group registration.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_function_app_id` | Function app resource ID |
| `public_function_app_name` | Function app name |

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_function_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Application settings | `map(string)` | `{}` | no |
| <a name="input_application_insights_connection_string"></a> [application\_insights\_connection\_string](#input\_application\_insights\_connection\_string) | Application Insights connection string. Required when enable\_application\_insights = true. | `string` | `null` | no |
| <a name="input_application_stack"></a> [application\_stack](#input\_application\_stack) | Application stack configuration. Set one runtime only. | <pre>object({<br/>    dotnet_version              = optional(string)<br/>    use_dotnet_isolated_runtime = optional(bool, true)<br/>    java_version                = optional(string)<br/>    node_version                = optional(string)<br/>    python_version              = optional(string)<br/>    powershell_core_version     = optional(string)<br/>    use_custom_runtime          = optional(bool, false)<br/>    docker = optional(object({<br/>      image_name        = string<br/>      image_tag         = string<br/>      registry_url      = optional(string)<br/>      registry_username = optional(string)<br/>      registry_password = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_enable_application_insights"></a> [enable\_application\_insights](#input\_enable\_application\_insights) | Connect to Application Insights for monitoring | `bool` | `true` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for this function app | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access to the function app | `bool` | `false` | no |
| <a name="input_enable_system_assigned_identity"></a> [enable\_system\_assigned\_identity](#input\_enable\_system\_assigned\_identity) | Enable system-assigned managed identity | `bool` | `false` | no |
| <a name="input_enable_vnet_integration"></a> [enable\_vnet\_integration](#input\_enable\_vnet\_integration) | Enable VNet integration for outbound traffic | `bool` | `false` | no |
| <a name="input_functions_extension_version"></a> [functions\_extension\_version](#input\_functions\_extension\_version) | Functions runtime version | `string` | `"~4"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Function App name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.azurewebsites.net. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_service_plan_id"></a> [service\_plan\_id](#input\_service\_plan\_id) | ID of the App Service Plan to host this function app | `string` | n/a | yes |
| <a name="input_storage_account_access_key"></a> [storage\_account\_access\_key](#input\_storage\_account\_access\_key) | Access key for the storage account | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account for the Functions runtime | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | List of User Assigned Identity IDs to assign | `list(string)` | `[]` | no |
| <a name="input_vnet_integration_subnet_id"></a> [vnet\_integration\_subnet\_id](#input\_vnet\_integration\_subnet\_id) | Subnet ID for VNet integration. Required when enable\_vnet\_integration = true. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | Default hostname of the function app |
| <a name="output_id"></a> [id](#output\_id) | Linux Function App resource ID |
| <a name="output_name"></a> [name](#output\_name) | Linux Function App name |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID (when enabled) |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_function_app_id"></a> [public\_function\_app\_id](#output\_public\_function\_app\_id) | Function app ID (for cross-project consumption) |
| <a name="output_public_function_app_name"></a> [public\_function\_app\_name](#output\_public\_function\_app\_name) | Function app name (for cross-project consumption) |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned managed identity tenant ID (when enabled) |
<!-- END_TF_DOCS -->

## Notes

- **AzureRM 4.x:** The `azurerm_function_app` resource was removed. Use `azurerm_linux_function_app`.
- **Storage account dependency:** Azure Functions require a storage account for triggers, bindings, and runtime state. The consumer creates this and passes the name and access key.
- **`storage_account_access_key` sensitivity:** This variable is marked `sensitive = true`. In a future version (v1.1.0), managed identity auth may be offered as an alternative.
- **Functions runtime version:** Default is `~4` (the current LTS version). Consumers can override this.
- **`use_dotnet_isolated_runtime`:** Defaults to `true`. The isolated worker model is recommended for .NET Functions.
- **Application Insights:** Enabled by default. The consumer provides the connection string from an existing Application Insights resource.
- **Same DNS zone as web apps:** Both `linux-web-app` and `function-app` use `privatelink.azurewebsites.net` for private endpoints.
- **Consumption plan gotcha:** When using a Consumption plan (`Y1`), `always_on` must be `false` and VNet integration has limitations. Azure will return errors for invalid combinations.
- **Naming:** CAF prefix for Function Apps is `func`. Example: `func-payments-dev-weu-001`.
