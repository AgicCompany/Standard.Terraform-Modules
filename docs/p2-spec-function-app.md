# Module: function-app

**Priority:** P2
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_linux_function_app` — Azure Linux Function App
- `azurerm_private_endpoint` — Private endpoint (when `enable_private_endpoint = true`)
- `azurerm_private_endpoint_dns_zone_group` — DNS zone group (when `enable_private_endpoint = true`)

## v1.0.0 Scope

A Linux Function App with secure defaults and private endpoint support. Supports both Consumption (`Y1`) and Premium (`EP*`) plans. The function app requires a storage account for runtime state — this is passed by the consumer.

### In Scope

- Function app creation on an existing service plan
- Application stack configuration (.NET, Node.js, Python, Java, PowerShell)
- Secure defaults (HTTPS only, minimum TLS 1.2, FTPS disabled, public access disabled)
- Private endpoint for `sites` subresource
- VNet integration for outbound traffic
- System-assigned and user-assigned managed identity support
- Application settings
- Storage account connection (required by Azure Functions runtime)
- Functions runtime version configuration

### Out of Scope (Deferred)

- Deployment slots
- Custom domains and SSL bindings
- IP restrictions
- CORS configuration
- Source control integration
- Key Vault reference integration for app settings (consumers configure this directly)
- Diagnostic settings (use the standalone `diagnostic-settings` module)
- Durable Functions specific configuration

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_private_endpoint` | `true` | Create a private endpoint for this function app |
| `enable_public_access` | `false` | Allow public network access |
| `enable_vnet_integration` | `false` | Enable VNet integration for outbound traffic |
| `enable_system_assigned_identity` | `false` | Enable system-assigned managed identity |
| `enable_application_insights` | `true` | Connect to Application Insights for monitoring |

## Private Endpoint Support

| Property | Value |
|----------|-------|
| Subresource name | `sites` |
| Private DNS zone | `privatelink.azurewebsites.net` |

Same DNS zone as linux-web-app — both are App Service resources under the hood.

### Variables (Private Endpoint)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `subnet_id` | string | Conditional | — | Subnet ID for private endpoint. Required when `enable_private_endpoint = true`. |
| `private_dns_zone_id` | string | Conditional | — | Private DNS zone ID. Required when `enable_private_endpoint = true`. |

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `service_plan_id` | string | Yes | — | ID of the App Service Plan |
| `storage_account_name` | string | Yes | — | Name of the storage account for the Functions runtime |
| `storage_account_access_key` | string | Yes | — | Access key for the storage account. See notes on managed identity alternative. |
| `application_stack` | object | No | `{}` | Application stack configuration (see below) |
| `app_settings` | map(string) | No | `{}` | Application settings |
| `functions_extension_version` | string | No | `"~4"` | Functions runtime version |
| `vnet_integration_subnet_id` | string | Conditional | — | Subnet ID for VNet integration. Required when `enable_vnet_integration = true`. |
| `application_insights_connection_string` | string | Conditional | — | Application Insights connection string. Required when `enable_application_insights = true`. |
| `user_assigned_identity_ids` | list(string) | No | `[]` | List of User Assigned Identity IDs to assign |

### Application Stack Variable Structure

```hcl
variable "application_stack" {
  type = object({
    dotnet_version              = optional(string)
    use_dotnet_isolated_runtime = optional(bool, true)
    java_version                = optional(string)
    node_version                = optional(string)
    python_version              = optional(string)
    powershell_core_version     = optional(string)
    use_custom_runtime          = optional(bool, false)
    docker = optional(object({
      image_name        = string
      image_tag         = string
      registry_url      = optional(string)
      registry_username = optional(string)
      registry_password = optional(string)
    }))
  })
  default     = {}
  description = "Application stack configuration. Set one runtime only."
}
```

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `default_hostname` | Default hostname of the function app |
| `principal_id` | System-assigned managed identity principal ID (when enabled) |
| `tenant_id` | System-assigned managed identity tenant ID (when enabled) |
| `private_endpoint_id` | Private endpoint resource ID (when enabled) |
| `private_ip_address` | Private IP address of the endpoint (when enabled) |
| `public_function_app_id` | Function app ID (public output) |
| `public_function_app_name` | Function app name (public output) |

## Deferred

- **Storage account managed identity auth** — Instead of passing `storage_account_access_key`, use managed identity with `storage_uses_managed_identity = true` and appropriate RBAC. Cleaner pattern, but adds complexity. Evaluate for v1.1.0.
- **Deployment slots** — Same as linux-web-app.
- **Durable Functions** — Requires additional storage configuration (task hub names, etc.). Add when demand exists.
- **Application Insights sampling** — Fine-grained control over telemetry sampling rates.
- **Elastic scale configuration** — `elastic_instance_minimum` for Premium plans.

## Notes

- **AzureRM 4.x:** The `azurerm_function_app` resource was removed. Use `azurerm_linux_function_app`. The interface is significantly different — `site_config` is restructured, `app_service_plan_id` becomes `service_plan_id`.
- **Storage account dependency:** Azure Functions require a storage account for triggers, bindings, and runtime state. The consumer creates this storage account (possibly via the `storage-account` module) and passes the name and access key. This is a hard Azure requirement, not a module design choice.
- **`storage_account_access_key` sensitivity:** This variable contains a secret. Mark it as `sensitive = true` in `variables.tf`. In the future (v1.1.0), offer managed identity auth as an alternative.
- **Functions runtime version:** Default is `~4` (the current LTS version). Version `~1`, `~2`, and `~3` are deprecated or reaching end of life. The module does not restrict this — consumers can override.
- **`use_dotnet_isolated_runtime`:** Defaults to `true`. The isolated worker model is the recommended approach for .NET Functions going forward. The in-process model is deprecated.
- **Application Insights:** Enabled by default via `enable_application_insights = true`. The consumer provides the connection string from an existing Application Insights resource. The module sets the `APPLICATIONINSIGHTS_CONNECTION_STRING` app setting.
- **Naming:** CAF prefix for Function Apps is `func`. Example: `func-payments-dev-weu-001`.
- **Same DNS zone as web apps:** Both `linux-web-app` and `function-app` use `privatelink.azurewebsites.net` for private endpoints. A single DNS zone can serve both.
- **Consumption plan gotcha:** When using a Consumption plan (`Y1`), `always_on` must be `false` and VNet integration has limitations. The module does not enforce these constraints — Azure will return errors for invalid combinations.
