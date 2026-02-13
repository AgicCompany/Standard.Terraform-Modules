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
  description = "NAT gateway name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===

variable "sku_name" {
  type        = string
  default     = "Standard"
  description = "SKU name for the NAT gateway"

  validation {
    condition     = var.sku_name == "Standard"
    error_message = "SKU name must be 'Standard'."
  }
}

variable "idle_timeout_in_minutes" {
  type        = number
  default     = 4
  description = "Idle timeout in minutes (4-120)"

  validation {
    condition     = var.idle_timeout_in_minutes >= 4 && var.idle_timeout_in_minutes <= 120
    error_message = "Idle timeout must be between 4 and 120 minutes."
  }
}

variable "zones" {
  type        = list(string)
  default     = []
  description = "Availability zones for the NAT gateway"
}

# === Tags ===

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
