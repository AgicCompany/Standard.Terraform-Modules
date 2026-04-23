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
  description = "Service Bus namespace name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "sku" {
  type        = string
  default     = "Standard"
  description = "SKU tier: Basic, Standard, or Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be \"Basic\", \"Standard\", or \"Premium\"."
  }
}

variable "capacity" {
  type        = number
  default     = 0
  description = "Messaging units for Premium SKU (1, 2, 4, 8, or 16). Must be 0 for Basic/Standard."

  validation {
    condition     = contains([0, 1, 2, 4, 8, 16], var.capacity)
    error_message = "Capacity must be 0 (Basic/Standard) or 1, 2, 4, 8, 16 (Premium)."
  }
}

variable "min_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version. Only \"1.2\" is supported; TLS 1.0/1.1 retired by Azure."

  validation {
    condition     = contains(["1.2"], var.min_tls_version)
    error_message = "Only TLS 1.2 is supported; TLS 1.0 and 1.1 were retired by Azure on 2025-10-20."
  }
}

variable "queues" {
  type = map(object({
    max_size_in_megabytes                   = optional(number, 1024)
    default_message_ttl                     = optional(string)
    lock_duration                           = optional(string)
    max_delivery_count                      = optional(number, 10)
    dead_lettering_on_message_expiration    = optional(bool, false)
    enable_partitioning                     = optional(bool, false)
    enable_batched_operations               = optional(bool, true)
    requires_session                        = optional(bool, false)
    requires_duplicate_detection            = optional(bool, false)
    duplicate_detection_history_time_window = optional(string)
  }))
  default     = {}
  description = "Map of queues to create. Key is the queue name."
}

variable "topics" {
  type = map(object({
    max_size_in_megabytes                   = optional(number, 1024)
    default_message_ttl                     = optional(string)
    enable_partitioning                     = optional(bool, false)
    enable_batched_operations               = optional(bool, true)
    requires_duplicate_detection            = optional(bool, false)
    duplicate_detection_history_time_window = optional(string)
    subscriptions = optional(map(object({
      max_delivery_count                   = optional(number, 10)
      lock_duration                        = optional(string)
      default_message_ttl                  = optional(string)
      dead_lettering_on_message_expiration = optional(bool, false)
      enable_batched_operations            = optional(bool, true)
      requires_session                     = optional(bool, false)
    })), {})
  }))
  default     = {}
  description = "Map of topics to create. Key is the topic name. Topics require Standard or Premium SKU."
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for this namespace"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access"
}

variable "enable_local_auth" {
  type        = bool
  default     = false
  description = "Enable local authentication (SAS keys). Disabled by default — use managed identity."
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
  description = "Private DNS zone ID for privatelink.servicebus.windows.net. Required when enable_private_endpoint = true."

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
