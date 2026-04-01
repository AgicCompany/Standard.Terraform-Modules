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
  description = "Managed Redis instance name (full CAF-compliant name, provided by consumer). Globally unique."
}

# === Required: Resource-Specific ===
variable "sku_name" {
  type        = string
  description = "SKU tier and capacity (e.g. Balanced_B10, ComputeOptimized_X10, MemoryOptimized_M20). See https://learn.microsoft.com/en-us/azure/redis/managed-redis-overview for valid sizes."

  validation {
    condition     = can(regex("^(Balanced_B[0-9]+|ComputeOptimized_X[0-9]+|MemoryOptimized_M[0-9]+)$", var.sku_name))
    error_message = "sku_name must match format: Balanced_B<n>, ComputeOptimized_X<n>, or MemoryOptimized_M<n>."
  }
}

# === Optional: Configuration ===
variable "high_availability_enabled" {
  type        = bool
  default     = true
  description = "Enable high availability. Cannot be changed after creation (forces replacement)."
}

variable "clustering_policy" {
  type        = string
  default     = "OSSCluster"
  description = "Clustering policy: OSSCluster, EnterpriseCluster, or NoCluster. Cannot be changed after creation (forces replacement)."

  validation {
    condition     = contains(["OSSCluster", "EnterpriseCluster", "NoCluster"], var.clustering_policy)
    error_message = "clustering_policy must be \"OSSCluster\", \"EnterpriseCluster\", or \"NoCluster\"."
  }
}

variable "eviction_policy" {
  type        = string
  default     = "VolatileLRU"
  description = "Eviction policy for the default database"

  validation {
    condition     = contains(["AllKeysLFU", "AllKeysLRU", "AllKeysRandom", "VolatileLRU", "VolatileLFU", "VolatileTTL", "VolatileRandom", "NoEviction"], var.eviction_policy)
    error_message = "eviction_policy must be one of: AllKeysLFU, AllKeysLRU, AllKeysRandom, VolatileLRU, VolatileLFU, VolatileTTL, VolatileRandom, NoEviction."
  }
}

variable "client_protocol" {
  type        = string
  default     = "Encrypted"
  description = "Client protocol: Encrypted (TLS) or Plaintext"

  validation {
    condition     = contains(["Encrypted", "Plaintext"], var.client_protocol)
    error_message = "client_protocol must be \"Encrypted\" or \"Plaintext\"."
  }
}

variable "modules" {
  type = list(object({
    name = string
    args = optional(string)
  }))
  default     = []
  description = "Redis modules to enable (RediSearch, RedisJSON, RedisBloom, RedisTimeSeries). Cannot be changed after creation (forces replacement)."

  validation {
    condition     = alltrue([for m in var.modules : contains(["RediSearch", "RedisJSON", "RedisBloom", "RedisTimeSeries"], m.name)])
    error_message = "Each module name must be one of: RediSearch, RedisJSON, RedisBloom, RedisTimeSeries."
  }
}

variable "geo_replication_group_name" {
  type        = string
  default     = null
  description = "Active-active geo-replication group name. All instances sharing this name are linked. Forces replacement."
}

# === Optional: Persistence ===
variable "persistence_aof_frequency" {
  type        = string
  default     = null
  description = "AOF persistence backup frequency. Only valid value is \"1s\". Mutually exclusive with RDB persistence and geo-replication."

  validation {
    condition     = var.persistence_aof_frequency == null || var.persistence_aof_frequency == "1s"
    error_message = "persistence_aof_frequency must be null or \"1s\"."
  }
}

variable "persistence_rdb_frequency" {
  type        = string
  default     = null
  description = "RDB persistence backup frequency: \"1h\", \"6h\", or \"12h\". Mutually exclusive with AOF persistence and geo-replication."

  validation {
    condition     = var.persistence_rdb_frequency == null || contains(["1h", "6h", "12h"], var.persistence_rdb_frequency)
    error_message = "persistence_rdb_frequency must be null or one of: \"1h\", \"6h\", \"12h\"."
  }
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for this instance"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access"
}

variable "access_keys_authentication_enabled" {
  type        = bool
  default     = false
  description = "Enable access key authentication. Disabled by default (Entra ID only)."
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
  description = "Private DNS zone ID for privatelink.redis.azure.net. Required when enable_private_endpoint = true."

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

# === Optional: Identity & Encryption ===
variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default     = null
  description = "Managed identity configuration. type must be \"SystemAssigned\", \"UserAssigned\", or \"SystemAssigned, UserAssigned\"."
}

variable "customer_managed_key" {
  type = object({
    key_vault_key_id = string
    identity_id      = string
  })
  default     = null
  description = "Customer-managed key for encryption. Requires an identity block with UserAssigned."
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}
