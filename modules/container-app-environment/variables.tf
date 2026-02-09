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
  description = "Container Apps Environment name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===
variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for environment logging"
}

# === Optional: Configuration ===
variable "infrastructure_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for VNet integration. Required when enable_internal_load_balancer = true."

  validation {
    condition     = var.infrastructure_subnet_id != null || !var.enable_internal_load_balancer
    error_message = "infrastructure_subnet_id is required when enable_internal_load_balancer is true."
  }
}

variable "workload_profiles" {
  type = map(object({
    workload_profile_type = string
    minimum_count         = number
    maximum_count         = number
  }))
  default     = {}
  description = "Dedicated workload profiles. Key is used as profile name. Empty map = Consumption only."
}

# === Optional: Feature Flags ===
variable "enable_internal_load_balancer" {
  type        = bool
  default     = true
  description = "Use internal load balancer. Requires VNet integration."
}

variable "enable_zone_redundancy" {
  type        = bool
  default     = false
  description = "Enable zone redundant deployment. Requires VNet integration."

  validation {
    condition     = !var.enable_zone_redundancy || var.infrastructure_subnet_id != null
    error_message = "infrastructure_subnet_id is required when enable_zone_redundancy is true."
  }
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
