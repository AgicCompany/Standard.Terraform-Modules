# Function App Flex Consumption (FC1) Module — Spec

## Problem

The public `function-app` module at `AgicCompany/Standard.Terraform-Modules` uses `azurerm_linux_function_app`, which does not support the Flex Consumption (FC1) hosting plan. FC1 requires a fundamentally different resource: `azurerm_function_app_flex_consumption`. The two resources have incompatible schemas and different operational characteristics.

Today the DTQ stack works around this with raw resources in `infrastructure/integration.tf`. That implementation is the reference for this new module.

## Recommendation: New Separate Module (`function-app-flex`)

Rather than extending the existing `function-app` module, create a new `function-app-flex` module. Reasons:

- **Different Terraform resource**: `azurerm_function_app_flex_consumption` vs `azurerm_linux_function_app` — cannot share the same module without heavy conditionals.
- **Different schema**: FC1 has no `site_config` block in the traditional sense; capacity is configured via `instance_memory_in_mb` and `maximum_instance_count`.
- **Different storage model**: FC1 uses `storage_container_type`, `storage_container_endpoint`, and `storage_authentication_type` instead of `storage_account_name` + `storage_account_access_key`.
- **Clean separation**: avoids conditional complexity that would make the existing module harder to maintain and test.

The existing `function-app` module remains unchanged.

## New Module: `function-app-flex`

### Variables

```hcl
variable "name" {
  type        = string
  description = "Name of the Function App."
}

variable "resource_group_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "service_plan_id" {
  type        = string
  description = "ID of the FC1 (sku_name = FC1) App Service Plan."
}

variable "runtime_name" {
  type        = string
  description = "Runtime stack: dotnet-isolated, python, node, java, powershell, or custom."
}

variable "runtime_version" {
  type        = string
  description = "Runtime version (e.g. '8.0' for dotnet-isolated, '3.11' for python)."
}

variable "instance_memory_in_mb" {
  type        = number
  default     = 2048
  description = "Memory per instance in MB. Allowed values: 512, 2048, 4096."
}

variable "maximum_instance_count" {
  type        = number
  default     = 10
}

variable "always_ready_instances" {
  type = map(object({
    instance_count = number
  }))
  default     = {}
  description = "Map of always-ready instance configurations keyed by name."
}

variable "storage_container_type" {
  type        = string
  default     = "blobContainer"
  description = "Storage container type for FC1 deployment package."
}

variable "storage_container_endpoint" {
  type        = string
  description = "URL of the blob container for deployment package storage."
}

variable "storage_authentication_type" {
  type        = string
  default     = "StorageAccountConnectionString"
  description = "StorageAccountConnectionString | SystemAssignedIdentity | UserAssignedIdentity"
}

variable "storage_user_assigned_identity_id" {
  type        = string
  default     = null
  description = "Resource ID of the user-assigned identity for storage auth. Required when storage_authentication_type = UserAssignedIdentity."
}

variable "identity_type" {
  type        = string
  default     = "None"
  description = "Managed identity type: None | SystemAssigned | UserAssigned"
}

variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "List of user-assigned identity resource IDs. Required when identity_type = UserAssigned."
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for VNet integration."
}

variable "https_only" {
  type    = bool
  default = true
}

variable "client_certificate_mode" {
  type    = string
  default = "Required"
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type    = bool
  default = false
}

variable "app_settings" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "private_endpoint_enabled" {
  type    = bool
  default = false
}

variable "private_endpoint_name" {
  type    = string
  default = null
  description = "Override the private endpoint resource name. Defaults to pe-{name}."
}

variable "private_service_connection_name" {
  type    = string
  default = null
  description = "Override the private service connection name. Defaults to psc-{name}."
}

variable "private_endpoint_subnet_id" {
  type    = string
  default = null
}

variable "private_endpoint_nic_name" {
  type    = string
  default = null
}

variable "private_dns_zone_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

### Main Resource

```hcl
resource "azurerm_function_app_flex_consumption" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  https_only                                     = var.https_only
  client_certificate_mode                        = var.client_certificate_mode
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled

  virtual_network_subnet_id = var.virtual_network_subnet_id
  maximum_instance_count    = var.maximum_instance_count

  runtime_name                       = var.runtime_name
  runtime_version                    = var.runtime_version
  storage_container_type             = var.storage_container_type
  storage_container_endpoint         = var.storage_container_endpoint
  storage_authentication_type        = var.storage_authentication_type
  storage_user_assigned_identity_id  = var.storage_user_assigned_identity_id

  instance_memory_in_mb = var.instance_memory_in_mb

  dynamic "always_ready" {
    for_each = var.always_ready_instances
    content {
      name           = always_ready.key
      instance_count = always_ready.value.instance_count
    }
  }

  app_settings = var.app_settings

  site_config {}

  dynamic "identity" {
    for_each = var.identity_type != "None" ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config,
      storage_container_endpoint,
      storage_access_key,
    ]
  }
}
```

### Private Endpoint (Optional)

Follows the standard module PE pattern, consistent with the PE naming override spec.

```hcl
resource "azurerm_private_endpoint" "this" {
  count = var.private_endpoint_enabled ? 1 : 0

  name                          = coalesce(var.private_endpoint_name, "pe-${var.name}")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = var.private_endpoint_nic_name

  private_service_connection {
    name                           = coalesce(var.private_service_connection_name, "psc-${var.name}")
    private_connection_resource_id = azurerm_function_app_flex_consumption.this.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = var.tags
}
```

### Outputs

```hcl
output "id" {
  value = azurerm_function_app_flex_consumption.this.id
}

output "name" {
  value = azurerm_function_app_flex_consumption.this.name
}

output "default_hostname" {
  value = azurerm_function_app_flex_consumption.this.default_hostname
}

output "identity" {
  value = azurerm_function_app_flex_consumption.this.identity
}

output "private_endpoint_id" {
  value = var.private_endpoint_enabled ? azurerm_private_endpoint.this[0].id : null
}
```

## `lifecycle { ignore_changes }` Rationale

The `app_settings`, `site_config`, `storage_container_endpoint`, and `storage_access_key` fields are ignored on subsequent applies. This follows the infrastructure-only management pattern: Terraform provisions the Function App shell and the dev team manages app settings and runtime configuration independently (via CI/CD or the Azure Portal). Without this, every `terraform apply` would reset app settings that the dev team has deployed.

## App Service Plan Note

FC1 Function Apps require an `azurerm_service_plan` with `sku_name = "FC1"` and `os_type = "Linux"`. The App Service Plan is **not** created inside this module — the caller is responsible for passing `service_plan_id`. This keeps the module composable and allows multiple Function Apps to share a single plan.

## Breaking Change vs `function-app` Module

This is a new module, not an upgrade. There is no breaking change to the existing `function-app` module. Callers migrating an existing Function App from a non-FC1 plan to FC1 will need to destroy and recreate the resource (different resource type), and should plan accordingly.

## Reference Implementation

`infrastructure/integration.tf` in this repository (`deghi-dtq`) contains the working raw-resource implementation for `azurerm_function_app_flex_consumption` and its associated private endpoints. The module spec above is a direct extraction of that pattern.

## Priority

High — required before DTQ integration layer can be migrated from raw resources to the module. Also needed by any project targeting serverless workloads on Azure.
