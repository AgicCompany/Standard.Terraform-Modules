# === Required ===
variable "name" {
  type        = string
  description = "Database name"
}

variable "server_id" {
  type        = string
  description = "ID of the SQL server to create the database on"
}

# === Optional: Configuration ===
variable "sku_name" {
  type        = string
  default     = "S0"
  description = "Database SKU (e.g., S0, P1, GP_Gen5_2)"
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

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
