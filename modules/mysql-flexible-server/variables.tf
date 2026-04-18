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

  validation {
    condition     = can(regex("^(B|GP|MO)_Standard_", var.sku_name))
    error_message = "sku_name must start with B_Standard_, GP_Standard_, or MO_Standard_ (e.g., B_Standard_B1ms, GP_Standard_D2ds_v4)."
  }
}

variable "version_number" {
  type        = string
  default     = "8.0.21"
  description = "MySQL version"

  validation {
    condition     = contains(["5.7", "8.0.21", "8.4"], var.version_number)
    error_message = "MySQL version must be one of: 5.7, 8.0.21, 8.4."
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
  description = "Administrator password. When non-null: min 12 chars; must include upper, lower, digit, and symbol."

  validation {
    condition = (
      var.administrator_password == null
      || (
        length(var.administrator_password) >= 12
        && can(regex("[A-Z]", var.administrator_password))
        && can(regex("[a-z]", var.administrator_password))
        && can(regex("[0-9]", var.administrator_password))
        && can(regex("[^A-Za-z0-9]", var.administrator_password))
      )
    )
    error_message = "When provided, password must be at least 12 characters and include upper, lower, digit, and symbol."
  }
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

variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for the MySQL server. Mutually exclusive with VNet delegation (delegated_subnet_id)."
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
  description = "Subnet ID for VNet integration (requires Microsoft.DBforMySQL/flexibleServers delegation). Mutually exclusive with private endpoint."
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Private DNS zone ID (privatelink.mysql.database.azure.com). Required when using delegation or private endpoint."

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
