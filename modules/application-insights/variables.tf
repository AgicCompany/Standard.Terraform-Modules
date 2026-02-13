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
  description = "Application Insights name (full CAF-compliant name, provided by consumer)"
}

variable "workspace_id" {
  type        = string
  description = "Log Analytics workspace resource ID (required for workspace-based Application Insights)"
}

# === Optional: Configuration ===

variable "application_type" {
  type        = string
  default     = "web"
  description = "Application type"

  validation {
    condition     = contains(["web", "ios", "java", "MobileCenter", "Node.JS", "other", "phone", "store"], var.application_type)
    error_message = "application_type must be one of: web, ios, java, MobileCenter, Node.JS, other, phone, store."
  }
}

variable "retention_in_days" {
  type        = number
  default     = 90
  description = "Data retention in days"

  validation {
    condition     = contains([30, 60, 90, 120, 180, 270, 365, 550, 730], var.retention_in_days)
    error_message = "retention_in_days must be one of: 30, 60, 90, 120, 180, 270, 365, 550, 730."
  }
}

variable "daily_data_cap_in_gb" {
  type        = number
  default     = null
  description = "Daily data volume cap in GB (null for unlimited)"
}

variable "daily_data_cap_notifications_disabled" {
  type        = bool
  default     = false
  description = "Disable notifications when daily data cap is hit"
}

variable "sampling_percentage" {
  type        = number
  default     = 100
  description = "Percentage of telemetry items to sample (0-100)"

  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "sampling_percentage must be between 0 and 100."
  }
}

# === Optional: Feature Flags ===

variable "disable_ip_masking" {
  type        = bool
  default     = false
  description = "Disable IP masking in logs"
}

variable "local_authentication_disabled" {
  type        = bool
  default     = true
  description = "Disable local (non-AAD) authentication. Disabled by default for security; set to false to allow API key auth."
}

variable "internet_ingestion_enabled" {
  type        = bool
  default     = false
  description = "Enable ingestion over public internet. Disabled by default for security."
}

variable "internet_query_enabled" {
  type        = bool
  default     = false
  description = "Enable querying over public internet. Disabled by default for security."
}

variable "force_customer_storage_for_profiler" {
  type        = bool
  default     = false
  description = "Force customer storage for profiler data"
}

# === Tags ===

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
