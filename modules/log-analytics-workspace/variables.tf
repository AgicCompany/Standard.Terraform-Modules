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
  description = "Log Analytics workspace name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "sku" {
  type        = string
  default     = "PerGB2018"
  description = "SKU of the Log Analytics workspace"

  validation {
    condition     = contains(["Free", "PerGB2018", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation"], var.sku)
    error_message = "SKU must be one of: Free, PerGB2018, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation."
  }
}

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "Data retention in days (30-730)"

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  type        = number
  default     = -1
  description = "Daily ingestion quota in GB (-1 for unlimited)"
}

# === Optional: Feature Flags ===
variable "enable_internet_ingestion" {
  type        = bool
  default     = false
  description = "Enable internet ingestion (default: disabled for security)"
}

variable "enable_internet_query" {
  type        = bool
  default     = false
  description = "Enable internet query access (default: disabled for security)"
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
