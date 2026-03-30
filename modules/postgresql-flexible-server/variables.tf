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
  description = "PostgreSQL Flexible Server name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "sku_name" {
  type        = string
  default     = "B_Standard_B1ms"
  description = "SKU name for the PostgreSQL Flexible Server (e.g., B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3)"

  validation {
    condition     = can(regex("^(B|GP|MO)_Standard_", var.sku_name))
    error_message = "sku_name must start with B_Standard_, GP_Standard_, or MO_Standard_ (e.g., B_Standard_B1ms, GP_Standard_D2s_v3)."
  }
}

variable "version_number" {
  type        = string
  default     = "16"
  description = "PostgreSQL major version"

  validation {
    condition     = contains(["12", "13", "14", "15", "16"], var.version_number)
    error_message = "PostgreSQL version must be one of: 12, 13, 14, 15, 16."
  }
}

variable "storage_mb" {
  type        = number
  default     = 32768
  description = "Storage size in MB (32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 8388608, 16777216)"
}

variable "storage_tier" {
  type        = string
  default     = null
  description = "Storage tier (P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80). Auto-selected if null."
}

variable "administrator_login" {
  type        = string
  default     = null
  description = "Administrator login name. Required when authentication.password_auth_enabled = true."
}

variable "administrator_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "Administrator password. Required when authentication.password_auth_enabled = true."
}

variable "backup_retention_days" {
  type        = number
  default     = 7
  description = "Backup retention days (7-35)"

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention must be between 7 and 35 days."
  }
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  default     = false
  description = "Enable geo-redundant backups"
}

variable "zone" {
  type        = string
  default     = null
  description = "Availability zone (1, 2, or 3)"
}

variable "high_availability" {
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default     = null
  description = "High availability configuration. Mode must be 'SameZone' or 'ZoneRedundant'."
}

variable "maintenance_window" {
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default     = null
  description = "Custom maintenance window"
}

variable "databases" {
  type = map(object({
    charset   = optional(string, "UTF8")
    collation = optional(string, "en_US.utf8")
  }))
  default     = {}
  description = "Map of databases to create. Key is used as the database name."
}

variable "server_configurations" {
  type        = map(string)
  default     = {}
  description = "Map of server configuration parameters. Key is the parameter name, value is the parameter value."
}

variable "firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default     = {}
  description = "Map of firewall rules. Key is used as the rule name. Only applicable when not VNet-integrated."
}

# === Optional: Feature Flags ===
variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access (default: disabled for security)"
}

variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for the PostgreSQL server. Mutually exclusive with VNet delegation (delegated_subnet_id)."
}

variable "enable_password_auth" {
  type        = bool
  default     = false
  description = "Enable password authentication. Disabled by default; use Entra ID where possible."
}

variable "enable_entra_auth" {
  type        = bool
  default     = false
  description = "Enable Microsoft Entra (AAD) authentication"
}

# === Private Networking ===
variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the private endpoint. Required when enable_private_endpoint = true."

  validation {
    condition     = var.subnet_id != null || !var.enable_private_endpoint
    error_message = "subnet_id is required when enable_private_endpoint is true."
  }
}

variable "delegated_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for VNet integration (requires Microsoft.DBforPostgreSQL/flexibleServers delegation). Mutually exclusive with private endpoint."
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Private DNS zone ID (privatelink.postgres.database.azure.com). Required when using delegation or private endpoint."

  validation {
    condition     = var.private_dns_zone_id != null || (var.delegated_subnet_id == null && !var.enable_private_endpoint)
    error_message = "private_dns_zone_id is required when delegated_subnet_id is set or enable_private_endpoint is true."
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

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
