# === Required ===
variable "name" {
  type        = string
  description = "Database name (full CAF-compliant name, provided by consumer)"
}

variable "server_id" {
  type        = string
  description = "ID of the SQL server to create the database on"
}

# === Optional: Configuration ===
variable "sku_name" {
  type        = string
  default     = "S0"
  description = "Database SKU (e.g., S0, P1, GP_Gen5_2, HS_Gen5_2, BC_Gen5_2)"

  validation {
    condition     = can(regex("^(Basic|S[0-9]+|P[1-9][0-9]*|GP_Gen[45]_[0-9]+|GP_S_Gen[45]_[0-9]+|BC_Gen[45]_[0-9]+|HS_Gen[45]_[0-9]+|DW[0-9]+c|DS[0-9]+|ElasticPool)$", var.sku_name))
    error_message = "sku_name must be a valid Azure SQL Database SKU (e.g., Basic, S0, P1, GP_Gen5_2, BC_Gen5_2, HS_Gen5_2)."
  }
}

variable "max_size_gb" {
  type        = number
  default     = 2
  description = "Maximum database size in GB"
}

variable "collation" {
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
  description = "Database collation"
}

variable "license_type" {
  type        = string
  default     = "LicenseIncluded"
  description = "License type: LicenseIncluded or BasePrice (Azure Hybrid Benefit)"

  validation {
    condition     = contains(["LicenseIncluded", "BasePrice"], var.license_type)
    error_message = "License type must be \"LicenseIncluded\" or \"BasePrice\"."
  }
}

variable "short_term_retention_days" {
  type        = number
  default     = 7
  description = "Point-in-time restore retention in days (1-35)"

  validation {
    condition     = var.short_term_retention_days >= 1 && var.short_term_retention_days <= 35
    error_message = "Short-term retention days must be between 1 and 35."
  }
}

# === Optional: Feature Flags ===
variable "enable_zone_redundancy" {
  type        = bool
  default     = false
  description = "Enable zone redundant deployment"
}

variable "enable_geo_redundant_backup" {
  type        = bool
  default     = true
  description = "Enable geo-redundant backup storage"
}

variable "enable_read_scale" {
  type        = bool
  default     = false
  description = "Enable read-only replicas for read scale-out"
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
      var.diagnostic_settings == null ? true
      : (var.diagnostic_settings.log_analytics_workspace_id != null
        || var.diagnostic_settings.storage_account_id != null
      || var.diagnostic_settings.eventhub_authorization_rule_id != null)
    )
    error_message = "At least one destination (log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id) is required when diagnostic_settings is set."
  }

  validation {
    condition = (
      var.diagnostic_settings == null ? true
      : (var.diagnostic_settings.log_analytics_destination_type == null
      || contains(["Dedicated", "AzureDiagnostics"], var.diagnostic_settings.log_analytics_destination_type))
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
