# ai-foundry

Provisions an Azure AI Foundry hub (`Microsoft.MachineLearningServices/workspaces` kind = Hub) with a default project. Optionally creates a private endpoint and diagnostic settings.

> **Note on resource flavour.** This module wraps the AML-workspace-based AI Foundry hub. The newer Cognitive-Services-backed "AI Foundry account" is a different Azure resource (`azurerm_cognitive_account` or `azurerm_ai_services`); use a different module for that. The private-link subresource for this module is `amlworkspace`, and the private DNS zones are `privatelink.api.azureml.ms` and `privatelink.notebooks.azure.net` — not `privatelink.cognitiveservices.azure.com`.

## Required role assignments

The hub's managed identity (system- or user-assigned) needs RBAC on the backing storage account and key vault to function. The module does not grant these; consumers must wire `azurerm_role_assignment` separately. Minimum:

- Storage account: `Storage Blob Data Contributor` to the hub MSI (for notebook scratch and run artifacts).
- Key Vault (non-CMK path): `Key Vault Secrets User` to the hub MSI.
- Key Vault (CMK path only): `Key Vault Crypto Service Encryption User` to the user-assigned identity referenced in the `encryption` block (covers get + wrap + unwrap).
- Avoid granting `Key Vault Administrator` to the hub MSI in production — it grants full data-plane control of the vault.

## ForceNew foot-guns

Changing any of these on the hub destroys it (and cascade-destroys the default project): `name`, `location`, `resource_group_name`, `key_vault_id`, `storage_account_id`, `high_business_impact_enabled`, the entire `encryption` block. Changing the project's `name`, `location`, or `high_business_impact_enabled` destroys the project. Toggling `encryption` from null to non-null (or vice versa) rebuilds the hub.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_ai_foundry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/ai_foundry) | resource |
| [azurerm_ai_foundry_project.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/ai_foundry_project) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_insights_id"></a> [application\_insights\_id](#input\_application\_insights\_id) | Optional Application Insights resource ID linked to the hub | `string` | `null` | no |
| <a name="input_container_registry_id"></a> [container\_registry\_id](#input\_container\_registry\_id) | Optional Container Registry resource ID linked to the hub | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the hub | `string` | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Optional diagnostic settings. null disables. Supports multi-sink (Log Analytics, storage account, Event Hub). enabled\_log\_categories = null -> all categories the resource supports. enabled\_metrics = null -> all metrics the resource supports. At least one of log\_analytics\_workspace\_id, storage\_account\_id, or eventhub\_authorization\_rule\_id is required when the object is non-null. | <pre>object({<br/>    name                           = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    enabled_log_categories         = optional(list(string))<br/>    enabled_metrics                = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Create a private endpoint to the hub. Requires subnet\_id. | `bool` | `false` | no |
| <a name="input_enable_public_network_access"></a> [enable\_public\_network\_access](#input\_enable\_public\_network\_access) | Enable public network access on the hub. Disabled by default for security; set true to allow public access. | `bool` | `false` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Customer-managed encryption key configuration. null disables (Microsoft-managed key). ForceNew — changing rebuilds the hub. | <pre>object({<br/>    key_id                    = string<br/>    key_vault_id              = string<br/>    user_assigned_identity_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_friendly_name"></a> [friendly\_name](#input\_friendly\_name) | Display name of the hub | `string` | `null` | no |
| <a name="input_high_business_impact_enabled"></a> [high\_business\_impact\_enabled](#input\_high\_business\_impact\_enabled) | Enable High Business Impact mode on the hub and project. ForceNew — changing rebuilds both. | `bool` | `false` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned managed identity resource IDs. Required when identity\_type includes UserAssigned. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Managed identity type. One of: SystemAssigned, UserAssigned, "SystemAssigned, UserAssigned" (note the literal space after the comma; AzureRM is strict). | `string` | `"SystemAssigned"` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Resource ID of the Key Vault backing the hub | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_managed_network_isolation_mode"></a> [managed\_network\_isolation\_mode](#input\_managed\_network\_isolation\_mode) | Optional managed network isolation. One of: null (omit the managed\_network block), Disabled, AllowOnlyApprovedOutbound, AllowInternetOutbound. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | AI Foundry hub name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_primary_user_assigned_identity"></a> [primary\_user\_assigned\_identity](#input\_primary\_user\_assigned\_identity) | UAMI resource ID representing the hub identity for encryption purposes (set when using CMK with a user-assigned identity) | `string` | `null` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Private DNS zone IDs to link to the private endpoint. AI Foundry typically needs two: privatelink.api.azureml.ms and privatelink.notebooks.azure.net. | `list(string)` | `[]` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Override the private endpoint name. Defaults to pep-<name>. | `string` | `null` | no |
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | Description of the default project | `string` | `null` | no |
| <a name="input_project_friendly_name"></a> [project\_friendly\_name](#input\_project\_friendly\_name) | Display name of the default project | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the default project. No default — derived names would silently exceed Azure project name length limits (~32 char max). Alphanumeric + hyphens. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | Resource ID of the storage account backing the hub | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet resource ID for the private endpoint. Required when enable\_private\_endpoint = true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_discovery_url"></a> [discovery\_url](#output\_discovery\_url) | Discovery URL for regional service endpoints |
| <a name="output_id"></a> [id](#output\_id) | AI Foundry hub resource ID |
| <a name="output_name"></a> [name](#output\_name) | AI Foundry hub name (echo of var.name; resource does not export it) |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned identity principal ID (null when not enabled) |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Private endpoint resource ID (null when disabled) |
| <a name="output_private_endpoint_ip_address"></a> [private\_endpoint\_ip\_address](#output\_private\_endpoint\_ip\_address) | Private endpoint NIC primary IP (null when disabled) |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | Default project resource ID |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Default project name |
| <a name="output_project_workspace_id"></a> [project\_workspace\_id](#output\_project\_workspace\_id) | Default project immutable workspace ID |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | System-assigned identity tenant ID (null when not enabled) |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Immutable workspace ID of the hub |
<!-- END_TF_DOCS -->
