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
  description = "SQL Server name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===
variable "azuread_administrator" {
  type = object({
    login_username = string
    object_id      = string
  })
  description = "Azure AD administrator configuration"
}

# === Optional: Configuration ===
variable "version_number" {
  type        = string
  default     = "12.0"
  description = "SQL Server version"
}

variable "administrator_login" {
  type        = string
  default     = null
  description = "SQL admin username. Required when enable_aad_only_auth = false."
}

variable "administrator_login_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "SQL admin password. Required when enable_aad_only_auth = false. When non-null: min 12 chars; must include upper, lower, digit, and symbol."

  validation {
    condition = (
      var.administrator_login_password == null
      || (
        length(var.administrator_login_password) >= 12
        && can(regex("[A-Z]", var.administrator_login_password))
        && can(regex("[a-z]", var.administrator_login_password))
        && can(regex("[0-9]", var.administrator_login_password))
        && can(regex("[^A-Za-z0-9]", var.administrator_login_password))
      )
    )
    error_message = "When provided, password must be at least 12 characters and include upper, lower, digit, and symbol."
  }
}

variable "min_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version. Only \"1.2\" is supported; TLS 1.0/1.1 retired by Azure."

  validation {
    condition     = contains(["1.2"], var.min_tls_version)
    error_message = "Only TLS 1.2 is supported; TLS 1.0 and 1.1 were retired by Azure on 2025-08-31."
  }
}

variable "connection_policy" {
  type        = string
  default     = "Default"
  description = "Connection policy: Default, Proxy, or Redirect"

  validation {
    condition     = contains(["Default", "Proxy", "Redirect"], var.connection_policy)
    error_message = "Connection policy must be \"Default\", \"Proxy\", or \"Redirect\"."
  }
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for this SQL server"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access"
}

variable "enable_outbound_networking_restriction" {
  type        = bool
  default     = false
  description = "Restrict outbound networking access from the SQL server"
}

variable "enable_aad_only_auth" {
  type        = bool
  default     = true
  description = "Restrict authentication to Azure AD only"
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
  description = "Private DNS zone ID for privatelink.database.windows.net. Required when enable_private_endpoint = true."

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
