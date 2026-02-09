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
  description = "App Service Plan name (full CAF-compliant name, provided by consumer)"
}

variable "sku_name" {
  type        = string
  description = "The SKU for the plan (e.g., B1, S1, P1v3, Y1)"
}

# === Optional: Configuration ===
variable "worker_count" {
  type        = number
  default     = 1
  description = "Number of workers (instances) allocated to this plan"
}

# === Optional: Feature Flags ===
variable "enable_zone_redundancy" {
  type        = bool
  default     = false
  description = "Enable zone redundant deployment"
}

variable "enable_per_site_scaling" {
  type        = bool
  default     = false
  description = "Enable per-app scaling instead of scaling all apps together"
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
