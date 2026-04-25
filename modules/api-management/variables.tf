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
  description = "API Management service name (full CAF-compliant name, provided by consumer)"
}

variable "publisher_name" {
  type        = string
  description = "Publisher name (shown in developer portal)"
}

variable "publisher_email" {
  type        = string
  description = "Publisher email (for notifications)"
}

# === Optional: Configuration ===
variable "sku_name" {
  type        = string
  default     = "Developer_1"
  description = "SKU in format {tier}_{capacity}"

  validation {
    condition     = can(regex("^(Consumption_|Developer_|Basic_|Standard_|Premium_)", var.sku_name))
    error_message = "sku_name must start with Consumption_, Developer_, Basic_, Standard_, or Premium_."
  }
}

variable "virtual_network_type" {
  type        = string
  default     = "None"
  description = "Type of VNet integration"

  validation {
    condition     = contains(["None", "External", "Internal"], var.virtual_network_type)
    error_message = "virtual_network_type must be None, External, or Internal."
  }
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for VNet integration (required when virtual_network_type is External or Internal)"
}

variable "min_api_version" {
  type        = string
  default     = null
  description = "Minimum API version to enforce"
}

variable "notification_sender_email" {
  type        = string
  default     = null
  description = "Email address for sending notifications"
}

variable "zones" {
  type        = list(string)
  default     = []
  description = "Availability zones (Premium SKU only)"
}

variable "additional_locations" {
  type = list(object({
    location                  = string
    zones                     = optional(list(string))
    virtual_network_subnet_id = optional(string)
  }))
  default     = []
  description = "Additional deployment locations for multi-region (Premium SKU only)"
}

variable "identity_type" {
  type        = string
  default     = "SystemAssigned"
  description = "Type of managed identity"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned", "None"], var.identity_type)
    error_message = "identity_type must be SystemAssigned, UserAssigned, 'SystemAssigned, UserAssigned', or None."
  }
}

variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "User-assigned identity IDs"
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for this API Management service"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access"
}

variable "client_certificate_enabled" {
  type        = bool
  default     = false
  description = "Enable client certificate authentication"
}

variable "gateway_disabled" {
  type        = bool
  default     = false
  description = "Disable gateway in the main region (for multi-region with External/Internal VNet)"
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
  description = "Private DNS zone ID for privatelink.azure-api.net. Required when enable_private_endpoint = true."

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
