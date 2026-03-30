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
  description = "Web App name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===
variable "service_plan_id" {
  type        = string
  description = "ID of the App Service Plan to host this web app"
}

# === Optional: Configuration ===
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
  default     = null
  description = "Application stack configuration. Set one runtime only."
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "Application settings (environment variables)"
}

variable "connection_strings" {
  type = map(object({
    type  = string
    value = string
  }))
  default     = {}
  sensitive   = true
  description = "Connection strings. Key is used as the connection string name."
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

variable "health_check_path" {
  type        = string
  default     = null
  description = "Health check path (e.g., /health)"
}

variable "health_check_eviction_time_in_min" {
  type        = number
  default     = 2
  description = "Time in minutes after which unhealthy instances are removed. Required when health_check_path is set."
}

variable "always_on" {
  type        = bool
  default     = true
  description = "Keep the app loaded at all times"
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
  description = "Create a private endpoint for this web app"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access to the web app"
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

# === Optional: Private Endpoint Overrides ===
variable "private_endpoint_name" {
  type        = string
  default     = null
  description = "Override the private endpoint resource name. Defaults to pep-{name}."
}

variable "private_service_connection_name" {
  type        = string
  default     = null
  description = "Override the private service connection name. Defaults to psc-{name}."
}

variable "private_endpoint_nic_name" {
  type        = string
  default     = null
  description = "Override the PE network interface name. Defaults to pep-{name}-nic."
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
