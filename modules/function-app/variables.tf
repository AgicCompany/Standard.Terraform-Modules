# === Required ===
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "name" {
  type        = string
  description = "Function App name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===
variable "service_plan_id" {
  type        = string
  description = "ID of the App Service Plan to host this function app"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account for the Functions runtime"
}

variable "storage_account_access_key" {
  type        = string
  sensitive   = true
  description = "Access key for the storage account"
}

# === Optional: Configuration ===
variable "application_stack" {
  type = object({
    dotnet_version              = optional(string)
    use_dotnet_isolated_runtime = optional(bool)
    java_version                = optional(string)
    node_version                = optional(string)
    python_version              = optional(string)
    powershell_core_version     = optional(string)
    use_custom_runtime          = optional(bool)
    docker = optional(object({
      image_name        = string
      image_tag         = string
      registry_url      = optional(string)
      registry_username = optional(string)
      registry_password = optional(string)
    }))
  })
  default     = null
  description = "Application stack configuration. Set one runtime only."
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "Application settings"
}

variable "functions_extension_version" {
  type        = string
  default     = "~4"
  description = "Functions runtime version"
}

variable "vnet_integration_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for VNet integration. Required when enable_vnet_integration = true."

  validation {
    condition     = var.vnet_integration_subnet_id != null || !var.enable_vnet_integration
    error_message = "vnet_integration_subnet_id is required when enable_vnet_integration is true."
  }
}

variable "application_insights_connection_string" {
  type        = string
  default     = null
  description = "Application Insights connection string. Required when enable_application_insights = true."

  validation {
    condition     = var.application_insights_connection_string != null || !var.enable_application_insights
    error_message = "application_insights_connection_string is required when enable_application_insights is true."
  }
}

variable "user_assigned_identity_ids" {
  type        = list(string)
  default     = []
  description = "List of User Assigned Identity IDs to assign"
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for this function app"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access to the function app"
}

variable "enable_vnet_integration" {
  type        = bool
  default     = false
  description = "Enable VNet integration for outbound traffic"
}

variable "enable_system_assigned_identity" {
  type        = bool
  default     = false
  description = "Enable system-assigned managed identity"
}

variable "enable_application_insights" {
  type        = bool
  default     = true
  description = "Connect to Application Insights for monitoring"
}

# === Private Endpoint ===
variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the private endpoint. Required when enable_private_endpoint = true."

  validation {
    condition     = var.subnet_id != null || !var.enable_private_endpoint
    error_message = "subnet_id is required when enable_private_endpoint is true."
  }
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Private DNS zone ID for privatelink.azurewebsites.net. Required when enable_private_endpoint = true."

  validation {
    condition     = var.private_dns_zone_id != null || !var.enable_private_endpoint
    error_message = "private_dns_zone_id is required when enable_private_endpoint is true."
  }
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
