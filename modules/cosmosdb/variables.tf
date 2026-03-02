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
  description = "Cosmos DB account name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "offer_type" {
  type        = string
  default     = "Standard"
  description = "Cosmos DB offer type"
}

variable "kind" {
  type        = string
  default     = "GlobalDocumentDB"
  description = "Cosmos DB account kind"

  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB", "Parse"], var.kind)
    error_message = "Kind must be one of: GlobalDocumentDB, MongoDB, Parse."
  }
}

variable "consistency_policy" {
  type = object({
    consistency_level       = string
    max_interval_in_seconds = optional(number, 5)
    max_staleness_prefix    = optional(number, 100)
  })
  default = {
    consistency_level = "Session"
  }
  description = "Consistency policy configuration"

  validation {
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_policy.consistency_level)
    error_message = "Consistency level must be one of: BoundedStaleness, Eventual, Session, Strong, ConsistentPrefix."
  }
}

variable "geo_locations" {
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool, false)
  }))
  default     = null
  description = "List of geo-locations for the Cosmos DB account. If null, uses the primary location with failover_priority 0."
}

variable "free_tier_enabled" {
  type        = bool
  default     = false
  description = "Enable Cosmos DB free tier (one per subscription)"
}

variable "automatic_failover_enabled" {
  type        = bool
  default     = false
  description = "Enable automatic failover for the account"
}

variable "minimal_tls_version" {
  type        = string
  default     = "Tls12"
  description = "Minimum TLS version"

  validation {
    condition     = var.minimal_tls_version == "Tls12"
    error_message = "minimal_tls_version must be \"Tls12\". TLS 1.0 and 1.1 were retired by Azure on 2025-08-31."
  }
}

variable "ip_range_filter" {
  type        = set(string)
  default     = []
  description = "Set of CIDR IP ranges to allow through the Cosmos DB firewall"
}

variable "backup" {
  type = object({
    type                = optional(string, "Periodic")
    interval_in_minutes = optional(number, 240)
    retention_in_hours  = optional(number, 8)
    storage_redundancy  = optional(string, "Geo")
    tier                = optional(string, null)
  })
  default     = {}
  description = "Backup policy configuration"
}

variable "capacity" {
  type = object({
    total_throughput_limit = number
  })
  default     = null
  description = "Account capacity configuration (total throughput limit in RU/s, -1 for unlimited)"
}

variable "sql_databases" {
  type = map(object({
    throughput     = optional(number, null)
    max_throughput = optional(number, null)
  }))
  default     = {}
  description = "Map of SQL API databases to create. Key is used as the database name."
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for this Cosmos DB account"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access (default: disabled for security)"
}

variable "enable_multiple_write_locations" {
  type        = bool
  default     = false
  description = "Enable multi-region writes"
}

variable "enable_local_auth" {
  type        = bool
  default     = false
  description = "Enable local (key-based) authentication. Disabled by default; use Entra ID where possible."
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
  description = "Private DNS zone ID for privatelink.documents.azure.com. Required when enable_private_endpoint = true."

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
