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

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
