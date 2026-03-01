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
  description = "Redis Cache name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "sku_name" {
  type        = string
  default     = "Basic"
  description = "SKU tier: Basic, Standard, or Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "sku_name must be \"Basic\", \"Standard\", or \"Premium\"."
  }
}

variable "family" {
  type        = string
  default     = "C"
  description = "SKU family: C (Basic/Standard) or P (Premium)"

  validation {
    condition     = contains(["C", "P"], var.family)
    error_message = "family must be \"C\" or \"P\"."
  }
}

variable "capacity" {
  type        = number
  default     = 0
  description = "Cache size: 0-6 for C family, 1-5 for P family"
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be \"1.0\", \"1.1\", or \"1.2\"."
  }
}

variable "redis_configuration" {
  type = object({
    maxmemory_policy                = optional(string, "volatile-lru")
    maxmemory_reserved              = optional(number)
    maxfragmentationmemory_reserved = optional(number)
    notify_keyspace_events          = optional(string)
    aof_backup_enabled              = optional(bool)
    rdb_backup_enabled              = optional(bool)
    rdb_backup_frequency            = optional(number)
    rdb_backup_max_snapshot_count   = optional(number)
    rdb_storage_connection_string   = optional(string)
  })
  default     = {}
  sensitive   = true
  description = "Redis configuration block. Premium-only fields (AOF, RDB) are ignored for lower SKUs. Marked sensitive due to rdb_storage_connection_string."
}

variable "patch_schedule" {
  type = object({
    day_of_week    = string
    start_hour_utc = optional(number, 0)
  })
  default     = null
  description = "Patch schedule for Redis updates. Premium SKU only."
}

variable "firewall_rules" {
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default     = {}
  description = "Map of firewall rules. Key is the rule name."
}

variable "zones" {
  type        = list(string)
  default     = []
  description = "Availability zones. Premium SKU only."
}

variable "replicas_per_master" {
  type        = number
  default     = null
  description = "Number of replicas per master. Premium SKU only."
}

variable "replicas_per_primary" {
  type        = number
  default     = null
  description = "Number of replicas per primary. Premium SKU only."
}

variable "redis_version" {
  type        = string
  default     = "6"
  description = "Redis version: 6"
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for this cache"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access"
}

variable "enable_non_ssl_port" {
  type        = bool
  default     = false
  description = "Enable the non-SSL port (6379). Not recommended."
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
  description = "Private DNS zone ID for privatelink.redis.cache.windows.net. Required when enable_private_endpoint = true."

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
