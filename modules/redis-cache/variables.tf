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
  default     = "Standard"
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

variable "min_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version. Only \"1.2\" is supported; TLS 1.0/1.1 retired by Azure."

  validation {
    condition     = contains(["1.2"], var.min_tls_version)
    error_message = "Only TLS 1.2 is supported; TLS 1.0 and 1.1 were retired by Azure on 2025-04-01."
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

  validation {
    condition = var.redis_configuration.maxmemory_policy == null || contains(
      ["volatile-lru", "allkeys-lru", "volatile-lfu", "allkeys-lfu", "volatile-random", "allkeys-random", "volatile-ttl", "noeviction"],
      var.redis_configuration.maxmemory_policy
    )
    error_message = "maxmemory_policy must be one of: volatile-lru, allkeys-lru, volatile-lfu, allkeys-lfu, volatile-random, allkeys-random, volatile-ttl, noeviction."
  }
}

variable "patch_schedule" {
  type = object({
    day_of_week    = string
    start_hour_utc = optional(number, 0)
  })
  default     = null
  description = "Patch schedule for Redis updates. Premium SKU only."

  validation {
    condition = var.patch_schedule == null || contains(
      ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "Everyday", "Weekend"],
      var.patch_schedule.day_of_week
    )
    error_message = "patch_schedule.day_of_week must be a day name (Monday-Sunday), \"Everyday\", or \"Weekend\"."
  }
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

# === Optional: Diagnostics ===
variable "diagnostic_settings" {
  type = object({
    name                           = optional(string)
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
    log_analytics_destination_type = optional(string)
    enabled_log_categories         = optional(list(string))
    enabled_metrics                = optional(list(string))
  })
  default     = null
  description = "Optional diagnostic settings. null disables. Supports multi-sink (Log Analytics, storage account, Event Hub). enabled_log_categories = null -> all categories the resource supports. enabled_metrics = null -> all metrics the resource supports. At least one of log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id is required when the object is non-null."

  validation {
    condition = (
      var.diagnostic_settings == null
      || var.diagnostic_settings.log_analytics_workspace_id != null
      || var.diagnostic_settings.storage_account_id != null
      || var.diagnostic_settings.eventhub_authorization_rule_id != null
    )
    error_message = "At least one destination (log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id) is required when diagnostic_settings is set."
  }

  validation {
    condition = (
      var.diagnostic_settings == null
      || var.diagnostic_settings.log_analytics_destination_type == null
      || contains(["Dedicated", "AzureDiagnostics"], var.diagnostic_settings.log_analytics_destination_type)
    )
    error_message = "log_analytics_destination_type must be \"Dedicated\" or \"AzureDiagnostics\" when set."
  }
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
