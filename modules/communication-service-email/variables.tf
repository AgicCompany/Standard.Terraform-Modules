# === Required ===

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region. Required by module convention but NOT passed to the underlying Communication Service or Email Communication Service resources (they are global). Kept on the module so consumers' standard wiring works unchanged."
}

variable "name" {
  type        = string
  description = "Communication Service name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===

variable "data_location" {
  type        = string
  description = "Region where the Communication Service and Email Communication Service store data at rest. Applied to both resources. ForceNew — cannot be changed in place. No default; consumers must choose explicitly because of data-residency policy implications."

  validation {
    condition = contains([
      "Africa", "Asia Pacific", "Australia", "Brazil", "Canada", "Europe",
      "France", "Germany", "India", "Japan", "Korea", "Norway",
      "Switzerland", "UAE", "UK", "United States", "usgov",
    ], var.data_location)
    error_message = "data_location must be one of the Azure-published values (see AzureRM docs for the current list)."
  }
}

# === Optional: Configuration ===

variable "email_service_name" {
  type        = string
  default     = null
  description = "Override the email service resource name. Defaults to <name>-email."
}

variable "domain_name" {
  type        = string
  default     = null
  description = "Fully qualified custom domain (e.g. mail.example.com). Required when enable_custom_domain = true. Ignored when enable_custom_domain = false (Azure-managed flow uses the literal AzureManagedDomain)."

  validation {
    condition     = var.domain_name == null || can(regex("^[a-z0-9.-]+\\.[a-z]{2,}$", var.domain_name))
    error_message = "domain_name must be a lowercase DNS name (e.g. mail.example.com)."
  }
}

variable "user_engagement_tracking_enabled" {
  type        = bool
  default     = false
  description = "Enable user engagement tracking on the email domain."
}

variable "sender_usernames" {
  type = map(object({
    username     = string
    display_name = optional(string)
  }))
  default     = {}
  description = "Map of sender usernames to provision. Keys are arbitrary identifiers used for for_each (changing a key replaces the sender). username is the local-part (e.g. no-reply). display_name is optional."

  validation {
    condition     = alltrue([for s in values(var.sender_usernames) : can(regex("^[a-zA-Z0-9._-]+$", s.username))])
    error_message = "Each sender username must be a non-empty local-part matching ^[a-zA-Z0-9._-]+$."
  }
}

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
  description = "Optional diagnostic settings attached to the Communication Service (the Email service does not currently expose diagnostic categories). At least one destination is required when non-null."

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

# === Optional: Feature Flags ===

variable "enable_custom_domain" {
  type        = bool
  default     = false
  description = "Use a customer-managed custom domain (CustomerManaged) instead of an Azure-managed *.azurecomm.net subdomain. Requires domain_name to be set."
}

# === Tags ===

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resources"
}
