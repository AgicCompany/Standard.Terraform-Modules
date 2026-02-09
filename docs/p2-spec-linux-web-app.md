# Module: linux-web-app

**Priority:** P2
**Status:** Not Started
**Target Version:** v1.0.0

## What It Creates

- `azurerm_linux_web_app` — Azure Linux Web App
- `azurerm_private_endpoint` — Private endpoint (when `enable_private_endpoint = true`)
- `azurerm_private_endpoint_dns_zone_group` — DNS zone group (when `enable_private_endpoint = true`)

## v1.0.0 Scope

A Linux web app with secure defaults, application stack configuration, and private endpoint support. Focuses on the most common deployment patterns: container-based and code-based (.NET, Node.js, Python, Java, PHP).

### In Scope

- Web app creation on an existing service plan
- Application stack configuration (Docker, .NET, Node.js, Python, Java, PHP)
- Secure defaults (HTTPS only, minimum TLS 1.2, FTPS disabled, public access disabled)
- Private endpoint for `sites` subresource
- VNet integration for outbound traffic
- System-assigned and user-assigned managed identity support
- Application settings and connection strings
- Health check path configuration
- Always-on setting

### Out of Scope (Deferred)

- Deployment slots (add in v1.1.0 or as separate module)
- Custom domains and SSL bindings
- Backup configuration
- Source control integration
- IP restrictions (consumers can manage these directly)
- CORS configuration
- Authentication/authorization settings (Easy Auth)
- Diagnostic settings (use the standalone `diagnostic-settings` module)

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `enable_private_endpoint` | `true` | Create a private endpoint for this web app |
| `enable_public_access` | `false` | Allow public network access to the web app |
| `enable_vnet_integration` | `false` | Enable VNet integration for outbound traffic |
| `enable_system_assigned_identity` | `false` | Enable system-assigned managed identity |

## Private Endpoint Support

| Property | Value |
|----------|-------|
| Subresource name | `sites` |
| Private DNS zone | `privatelink.azurewebsites.net` |

### Variables (Private Endpoint)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `subnet_id` | string | Conditional | — | Subnet ID for private endpoint. Required when `enable_private_endpoint = true`. |
| `private_dns_zone_id` | string | Conditional | — | Private DNS zone ID. Required when `enable_private_endpoint = true`. |

## Variables

Beyond the standard interface (`resource_group_name`, `location`, `name`, `tags`):

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `service_plan_id` | string | Yes | — | ID of the App Service Plan to host this web app |
| `application_stack` | object | No | `{}` | Application stack configuration (see below) |
| `app_settings` | map(string) | No | `{}` | Application settings (environment variables) |
| `connection_strings` | map(object) | No | `{}` | Connection strings (see below) |
| `vnet_integration_subnet_id` | string | Conditional | — | Subnet ID for VNet integration. Required when `enable_vnet_integration = true`. |
| `health_check_path` | string | No | `null` | Health check path (e.g., `/health`) |
| `always_on` | bool | No | `true` | Keep the app loaded at all times |
| `user_assigned_identity_ids` | list(string) | No | `[]` | List of User Assigned Identity IDs to assign |

### Application Stack Variable Structure

```hcl
variable "application_stack" {
  type = object({
    docker_image_name        = optional(string)
    docker_registry_url      = optional(string)
    docker_registry_username = optional(string)
    docker_registry_password = optional(string)
    dotnet_version           = optional(string)
    java_version             = optional(string)
    java_server              = optional(string)
    java_server_version      = optional(string)
    node_version             = optional(string)
    php_version              = optional(string)
    python_version           = optional(string)
  })
  default     = {}
  description = "Application stack configuration. Set one runtime only."
}
```

### Connection Strings Variable Structure

```hcl
variable "connection_strings" {
  type = map(object({
    type  = string  # SQLAzure, SQLServer, Custom, MySQL, PostgreSQL, etc.
    value = string
  }))
  default     = {}
  description = "Connection strings. Key is used as the connection string name."
}
```

## Outputs

Beyond the standard outputs (`id`, `name`):

| Output | Description |
|--------|-------------|
| `default_hostname` | Default hostname of the web app |
| `outbound_ip_addresses` | Outbound IP addresses (comma-separated) |
| `principal_id` | System-assigned managed identity principal ID (when enabled) |
| `tenant_id` | System-assigned managed identity tenant ID (when enabled) |
| `private_endpoint_id` | Private endpoint resource ID (when enabled) |
| `private_ip_address` | Private IP address of the endpoint (when enabled) |
| `public_web_app_id` | Web app ID (public output for cross-project consumption) |
| `public_web_app_name` | Web app name (public output for cross-project consumption) |
| `public_web_app_default_hostname` | Default hostname (public output) |

## Deferred

- **Deployment slots** — Common pattern for blue/green deployments. Evaluate as v1.1.0 or standalone `linux-web-app-slot` module.
- **Custom domains** — Requires certificate management. Better handled at the project level or via a dedicated module.
- **IP restrictions** — Consumers can add `azurerm_linux_web_app` `ip_restriction` blocks directly or manage via the `site_config` variable in a future version.
- **Easy Auth** — Authentication/authorization settings. Complex and project-specific.
- **Backup configuration** — Requires a storage account. Add when demand materializes.

## Notes

- **AzureRM 4.x:** The `azurerm_app_service` resource was removed. Use `azurerm_linux_web_app`. The `service_plan_id` replaces `app_service_plan_id`.
- **site_config complexity:** The `site_config` block in `azurerm_linux_web_app` is large (30+ attributes). We expose the most common settings as top-level variables (`always_on`, `health_check_path`, `application_stack`) rather than exposing the entire `site_config` object. This keeps the interface manageable. Additional `site_config` attributes can be exposed in minor versions as needed.
- **Connection strings vs app settings:** Connection strings are a legacy App Service feature. For new applications, prefer using app settings with Key Vault references. Connection strings are included for backward compatibility.
- **VNet integration vs private endpoint:** These serve different purposes. Private endpoint controls *inbound* traffic to the app. VNet integration controls *outbound* traffic from the app. Both can be enabled simultaneously.
- **Always-on:** Defaults to `true`. Required for continuous health checks and to prevent the app from being unloaded due to inactivity. Not available on Consumption plans — the module does not validate this.
- **Docker registry credentials:** If using a private container registry, `docker_registry_username` and `docker_registry_password` are passed as app settings by Azure. For ACR, prefer using managed identity (`acr_use_managed_identity_credentials`). This is deferred to a future version.
- **Naming:** CAF prefix for Web Apps is `app`. Example: `app-payments-dev-weu-001`.
- **FTPS state:** Defaults to `Disabled`. FTP/FTPS is a legacy deployment method. Modern deployments use CI/CD pipelines or container registries.
