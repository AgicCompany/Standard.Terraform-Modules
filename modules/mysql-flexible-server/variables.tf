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
  description = "MySQL Flexible Server name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "sku_name" {
  type        = string
  default     = "B_Standard_B1ms"
  description = "SKU name for the MySQL Flexible Server (e.g., B_Standard_B1ms, GP_Standard_D2ds_v4, MO_Standard_E4s_v3)"
}

variable "version_number" {
  type        = string
  default     = "8.0.21"
  description = "MySQL version"

  validation {
    condition     = contains(["5.7", "8.0.21"], var.version_number)
    error_message = "MySQL version must be one of: 5.7, 8.0.21."
  }
}

variable "storage" {
  type = object({
    size_gb           = optional(number, 20)
    iops              = optional(number)
    auto_grow_enabled = optional(bool, true)
  })
  default     = {}
  description = "Storage configuration for the MySQL Flexible Server"
}

variable "administrator_login" {
  type        = string
  default     = null
  description = "Administrator login name"
}

variable "administrator_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "Administrator password"
}

variable "backup_retention_days" {
  type        = number
  default     = 7
  description = "Backup retention days (1-35)"

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "Backup retention must be between 1 and 35 days."
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
    charset   = optional(string, "utf8mb4")
    collation = optional(string, "utf8mb4_unicode_ci")
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

# === VNet Integration ===
variable "delegated_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for VNet integration (requires Microsoft.DBforMySQL/flexibleServers delegation). Mutually exclusive with public access."
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Private DNS zone ID for VNet-integrated server (e.g., privatelink.mysql.database.azure.com). Required when delegated_subnet_id is set."

  validation {
    condition     = var.private_dns_zone_id != null || var.delegated_subnet_id == null
    error_message = "private_dns_zone_id is required when delegated_subnet_id is set."
  }
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
