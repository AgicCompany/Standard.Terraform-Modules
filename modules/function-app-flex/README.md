# function-app-flex

**Complexity:** Medium

Creates an Azure Function App on the Flex Consumption (FC1) hosting plan (`azurerm_function_app_flex_consumption`). Supports configurable runtimes, per-instance memory, always-ready instances, flexible storage authentication, VNet integration, and private endpoint.

## Usage

```hcl
module "function_app_flex" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/function-app-flex?ref=function-app-flex/v1.0.0"

  resource_group_name = "rg-myapp-dev-weu-001"
  location            = "westeurope"
  name                = "func-myapp-dev-weu-001"

  service_plan_id            = module.app_service_plan.id  # must be FC1 SKU
  runtime_name               = "dotnet-isolated"
  runtime_version            = "8.0"
  storage_container_endpoint = "https://${module.storage.name}.blob.core.windows.net/deployments"

  # PE is enabled by default — provide subnet and DNS zone
  private_endpoint_subnet_id = module.vnet.subnet_ids["snet-pe"]
  private_dns_zone_ids       = [module.dns.zone_ids["privatelink.azurewebsites.net"]]

  tags = var.tags
}
```

## Features

- Flex Consumption (FC1) Function App via `azurerm_function_app_flex_consumption`
- Configurable runtime: dotnet-isolated, python, node, java, powershell, custom
- Per-instance memory: 512, 2048 (default), or 4096 MB
- Maximum instance count and always-ready instance configuration
- Flexible storage authentication: connection string, SystemAssigned, or UserAssigned identity
- Managed identity: None (default), SystemAssigned, or UserAssigned
- VNet integration for outbound traffic (`virtual_network_subnet_id`)
- Private endpoint with CAF-compliant naming (`pep-{name}`) and override variables
- `lifecycle { ignore_changes }` on `app_settings` and `site_config` — infra shell pattern; settings managed by dev teams via CI/CD

## Security Defaults

| Setting | Default |
|---------|---------|
| HTTPS only | `true` |
| Client certificate mode | `Required` |
| WebDeploy basic auth | `false` |
| Private endpoint | `true` |

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_function_app_flex_id` | Function App resource ID (for cross-project consumption) |
| `public_function_app_flex_name` | Function App name (for cross-project consumption) |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
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
| [azurerm_function_app_flex_consumption.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app_flex_consumption) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_always_ready_instances"></a> [always\_ready\_instances](#input\_always\_ready\_instances) | Map of always-ready instance configurations keyed by function name. | <pre>map(object({<br/>    instance_count = number<br/>  }))</pre> | `{}` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Application settings. Ignored on subsequent applies (managed by dev teams via CI/CD). | `map(string)` | `{}` | no |
| <a name="input_client_certificate_mode"></a> [client\_certificate\_mode](#input\_client\_certificate\_mode) | Client certificate mode: Required, Optional, or OptionalInteractiveUser. | `string` | `"Required"` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Optional diagnostic settings. null disables. Supports multi-sink (Log Analytics, storage account, Event Hub). enabled\_log\_categories = null -> all categories the resource supports. enabled\_metrics = null -> all metrics the resource supports. At least one of log\_analytics\_workspace\_id, storage\_account\_id, or eventhub\_authorization\_rule\_id is required when the object is non-null. | <pre>object({<br/>    name                           = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    enabled_log_categories         = optional(list(string))<br/>    enabled_metrics                = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint for the Function App. | `bool` | `true` | no |
| <a name="input_https_only"></a> [https\_only](#input\_https\_only) | Require HTTPS connections. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of user-assigned identity resource IDs. Required when identity\_type = UserAssigned. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Managed identity type: None, SystemAssigned, or UserAssigned. | `string` | `"None"` | no |
| <a name="input_instance_memory_in_mb"></a> [instance\_memory\_in\_mb](#input\_instance\_memory\_in\_mb) | Memory per instance in MB. | `number` | `2048` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region. | `string` | n/a | yes |
| <a name="input_maximum_instance_count"></a> [maximum\_instance\_count](#input\_maximum\_instance\_count) | Maximum number of instances for scaling. | `number` | `10` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Function App (full CAF-compliant name, provided by consumer). | `string` | n/a | yes |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Private DNS zone IDs for the PE DNS zone group. | `list(string)` | `[]` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Override the private endpoint resource name. Defaults to pep-{name}. | `string` | `null` | no |
| <a name="input_private_endpoint_nic_name"></a> [private\_endpoint\_nic\_name](#input\_private\_endpoint\_nic\_name) | Override the PE network interface name. Defaults to pep-{name}-nic. | `string` | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Subnet ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Override the private service connection name. Defaults to psc-{name}. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group. | `string` | n/a | yes |
| <a name="input_runtime_name"></a> [runtime\_name](#input\_runtime\_name) | Runtime stack: dotnet-isolated, python, node, java, powershell, or custom. | `string` | n/a | yes |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | Runtime version (e.g. '8.0' for dotnet-isolated, '3.11' for python). | `string` | n/a | yes |
| <a name="input_service_plan_id"></a> [service\_plan\_id](#input\_service\_plan\_id) | ID of the FC1 (sku\_name = FC1) App Service Plan. | `string` | n/a | yes |
| <a name="input_storage_authentication_type"></a> [storage\_authentication\_type](#input\_storage\_authentication\_type) | Storage auth type: StorageAccountConnectionString, SystemAssignedIdentity, or UserAssignedIdentity. | `string` | `"StorageAccountConnectionString"` | no |
| <a name="input_storage_container_endpoint"></a> [storage\_container\_endpoint](#input\_storage\_container\_endpoint) | URL of the blob container for deployment package storage. | `string` | n/a | yes |
| <a name="input_storage_container_type"></a> [storage\_container\_type](#input\_storage\_container\_type) | Storage container type for FC1 deployment package. | `string` | `"blobContainer"` | no |
| <a name="input_storage_user_assigned_identity_id"></a> [storage\_user\_assigned\_identity\_id](#input\_storage\_user\_assigned\_identity\_id) | Resource ID of the user-assigned identity for storage auth. Required when storage\_authentication\_type = UserAssignedIdentity. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id) | Subnet ID for VNet integration (outbound traffic). | `string` | `null` | no |
| <a name="input_webdeploy_publish_basic_authentication_enabled"></a> [webdeploy\_publish\_basic\_authentication\_enabled](#input\_webdeploy\_publish\_basic\_authentication\_enabled) | Enable basic authentication for web deploy. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_hostname"></a> [default\_hostname](#output\_default\_hostname) | Default hostname of the Function App. |
| <a name="output_id"></a> [id](#output\_id) | Function App resource ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity block (principal\_id, tenant\_id). |
| <a name="output_name"></a> [name](#output\_name) | Function App name. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID. |
| <a name="output_public_function_app_flex_id"></a> [public\_function\_app\_flex\_id](#output\_public\_function\_app\_flex\_id) | Function App resource ID (for cross-project consumption). |
| <a name="output_public_function_app_flex_name"></a> [public\_function\_app\_flex\_name](#output\_public\_function\_app\_flex\_name) | Function App name (for cross-project consumption). |
<!-- END_TF_DOCS -->

## Notes

- **FC1 plan required:** `service_plan_id` must reference an App Service Plan with `sku_name = "FC1"`. Use the `app-service-plan` module.
- **Storage container:** The blob container at `storage_container_endpoint` must exist before apply. Create it via the `storage-account` module with blob PE enabled.
- **App settings lifecycle:** `app_settings` has `ignore_changes` — values set at creation are not tracked on subsequent applies. Dev teams manage settings via CI/CD pipeline or the portal.
- **Private endpoint DNS:** Use `privatelink.azurewebsites.net` as the private DNS zone for the PE DNS group.
- **VNet integration vs PE:** `virtual_network_subnet_id` controls outbound traffic (VNet integration). `private_endpoint_subnet_id` controls inbound traffic (PE). Both can be set simultaneously.
