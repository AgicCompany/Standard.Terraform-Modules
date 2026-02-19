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
  description = "Static Web App name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "sku_tier" {
  type        = string
  default     = "Free"
  description = "SKU tier for the Static Web App"

  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "SKU tier must be one of: Free, Standard."
  }
}

variable "sku_size" {
  type        = string
  default     = "Free"
  description = "SKU size for the Static Web App"

  validation {
    condition     = contains(["Free", "Standard"], var.sku_size)
    error_message = "SKU size must be one of: Free, Standard."
  }
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = "Application settings (environment variables)"
}

# === Optional: Feature Flags ===
variable "configuration_file_changes_enabled" {
  type        = bool
  default     = true
  description = "Allow configuration file changes"
}

variable "preview_environments_enabled" {
  type        = bool
  default     = true
  description = "Enable preview environments for pull requests"
}

variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for the Static Web App. Requires Standard SKU."
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access"
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
  description = "Private DNS zone ID for privatelink.azurestaticapps.net. Required when enable_private_endpoint = true."

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
