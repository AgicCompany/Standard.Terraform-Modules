# linux-web-app

**Complexity:** High

Creates an Azure Linux Web App with secure defaults, application stack configuration, and optional private endpoint.

## Usage

```hcl
module "web_app" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/linux-web-app?ref=linux-web-app/v1.0.0"

  resource_group_name = "rg-app-dev-weu-001"
  location            = "westeurope"
  name                = "app-payments-dev-weu-001"
  service_plan_id     = module.app_plan.id

  application_stack = {
    dotnet_version = "8.0"
  }

  subnet_id          = module.vnet.subnet_ids["pe-subnet"]
  private_dns_zone_id = module.dns_webapps.id

  tags = local.common_tags
}
```

## Features

- Application stack support (Docker, .NET, Node.js, Python, Java, PHP)
- Secure defaults (HTTPS only, minimum TLS 1.2, FTPS disabled, public access disabled)
- Private endpoint for `sites` subresource
- VNet integration for outbound traffic
- System-assigned and user-assigned managed identity support
- Application settings and connection strings
- Health check path configuration
- Always-on setting

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| HTTPS only | Enabled | -- (hardcoded) |
| Minimum TLS | 1.2 | -- (hardcoded) |
| FTPS | Disabled | -- (hardcoded) |
| Public access | Disabled | `enable_public_access` |
| Private endpoint | Enabled | `enable_private_endpoint` |
| Always-on | Enabled | `always_on` |

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
| `public_web_app_id` | Web app resource ID |
| `public_web_app_name` | Web app name |
| `public_web_app_default_hostname` | Default hostname |

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
| [azurerm_linux_web_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | Keep the app loaded at all times | `bool` | `true` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Application settings (environment variables) | `map(string)` | `{}` | no |
| <a name="input_application_stack"></a> [application\_stack](#input\_application\_stack) | Application stack configuration. Set one runtime only. | <pre>object({<br/>    docker_image_name        = optional(string)<br/>    docker_registry_url      = optional(string)<br/>    docker_registry_username = optional(string)<br/>    docker_registry_password = optional(string)<br/>    dotnet_version           = optional(string)<br/>    java_version             = optional(string)<br/>    java_server              = optional(string)<br/>    java_server_version      = optional(string)<br/>    node_version             = optional(string)<br/>    php_version              = optional(string)<br/>    python_version           = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | Connection strings. Key is used as the connection string name. (sensitive) | <pre>map(object({<br/>    type  = string<br/>    value = string<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for this web app | `bool` | `true` | no |
| <a name="input_enable_public_access"></a> [enable\_public\_access](#input\_enable\_public\_access) | Allow public network access to the web app | `bool` | `false` | no |
| <a name="input_enable_system_assigned_identity"></a> [enable\_system\_assigned\_identity](#input\_enable\_system\_assigned\_identity) | Enable system-assigned managed identity | `bool` | `false` | no |
| <a name="input_enable_vnet_integration"></a> [enable\_vnet\_integration](#input\_enable\_vnet\_integration) | Enable VNet integration for outbound traffic | `bool` | `false` | no |
| <a name="input_health_check_eviction_time_in_min"></a> [health\_check\_eviction\_time\_in\_min](#input\_health\_check\_eviction\_time\_in\_min) | Time in minutes after which unhealthy instances are removed. Required when health\_check\_path is set. | `number` | `2` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Health check path (e.g., /health) | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Web App name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private DNS zone ID for privatelink.azurewebsites.net. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_service_plan_id"></a> [service\_plan\_id](#input\_service\_plan\_id) | ID of the App Service Plan to host this web app | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | List of User Assigned Identity IDs to assign | `list(string)` | `[]` | no |
| <a name="input_vnet_integration_subnet_id"></a> [vnet\_integration\_subnet\_id](#input\_vnet\_integration\_subnet\_id) | Subnet ID for VNet integration. Required when enable\_vnet\_integration = true. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | Default hostname of the web app |
| <a name="output_id"></a> [id](#output\_id) | Linux Web App resource ID |
| <a name="output_name"></a> [name](#output\_name) | Linux Web App name |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | Outbound IP addresses (comma-separated) |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID (when enabled) |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (when enabled) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint (when enabled) |
| <a name="output_public_web_app_default_hostname"></a> [public\_web\_app\_default\_hostname](#output\_public\_web\_app\_default\_hostname) | Default hostname (for cross-project consumption) |
| <a name="output_public_web_app_id"></a> [public\_web\_app\_id](#output\_public\_web\_app\_id) | Web app ID (for cross-project consumption) |
| <a name="output_public_web_app_name"></a> [public\_web\_app\_name](#output\_public\_web\_app\_name) | Web app name (for cross-project consumption) |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned managed identity tenant ID (when enabled) |
<!-- END_TF_DOCS -->

## Notes

- **AzureRM 4.x:** The `azurerm_app_service` resource was removed. Use `azurerm_linux_web_app`. The `service_plan_id` replaces `app_service_plan_id`.
- **VNet integration vs private endpoint:** Private endpoint controls *inbound* traffic to the app. VNet integration controls *outbound* traffic from the app. Both can be enabled simultaneously.
- **Always-on:** Defaults to `true`. Not available on Consumption plans -- the module does not validate this.
- **Connection strings vs app settings:** Connection strings are a legacy App Service feature. For new applications, prefer using app settings with Key Vault references.
- **FTPS state:** Defaults to `Disabled`. Modern deployments use CI/CD pipelines or container registries.
- **Naming:** CAF prefix for Web Apps is `app`. Example: `app-payments-dev-weu-001`.
