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
  description = "AI Foundry hub name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===

variable "storage_account_id" {
  type        = string
  description = "Resource ID of the storage account backing the hub"
}

variable "key_vault_id" {
  type        = string
  description = "Resource ID of the Key Vault backing the hub"
}

variable "project_name" {
  type        = string
  description = "Name of the default project. No default — derived names would silently exceed Azure project name length limits (~32 char max). Alphanumeric + hyphens."
}

# === Optional: Configuration ===

variable "application_insights_id" {
  type        = string
  default     = null
  description = "Optional Application Insights resource ID linked to the hub"
}

variable "container_registry_id" {
  type        = string
  default     = null
  description = "Optional Container Registry resource ID linked to the hub"
}

variable "description" {
  type        = string
  default     = null
  description = "Description of the hub"
}

variable "friendly_name" {
  type        = string
  default     = null
  description = "Display name of the hub"
}

variable "project_description" {
  type        = string
  default     = null
  description = "Description of the default project"
}

variable "project_friendly_name" {
  type        = string
  default     = null
  description = "Display name of the default project"
}

variable "identity_type" {
  type        = string
  default     = "SystemAssigned"
  description = "Managed identity type. One of: SystemAssigned, UserAssigned, \"SystemAssigned, UserAssigned\" (note the literal space after the comma; AzureRM is strict)."

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be exactly one of: SystemAssigned, UserAssigned, \"SystemAssigned, UserAssigned\"."
  }
}

variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "User-assigned managed identity resource IDs. Required when identity_type includes UserAssigned."
}

variable "primary_user_assigned_identity" {
  type        = string
  default     = null
  description = "UAMI resource ID representing the hub identity for encryption purposes (set when using CMK with a user-assigned identity)"
}

variable "managed_network_isolation_mode" {
  type        = string
  default     = null
  description = "Optional managed network isolation. One of: null (omit the managed_network block), Disabled, AllowOnlyApprovedOutbound, AllowInternetOutbound."

  validation {
    condition     = var.managed_network_isolation_mode == null ? true : contains(["Disabled", "AllowOnlyApprovedOutbound", "AllowInternetOutbound"], var.managed_network_isolation_mode)
    error_message = "managed_network_isolation_mode must be null, Disabled, AllowOnlyApprovedOutbound, or AllowInternetOutbound."
  }
}

variable "high_business_impact_enabled" {
  type        = bool
  default     = false
  description = "Enable High Business Impact mode on the hub and project. ForceNew — changing rebuilds both."
}

variable "encryption" {
  type = object({
    key_id                    = string
    key_vault_id              = string
    user_assigned_identity_id = optional(string)
  })
  default     = null
  description = "Customer-managed encryption key configuration. null disables (Microsoft-managed key). ForceNew — changing rebuilds the hub."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet resource ID for the private endpoint. Required when enable_private_endpoint = true."

  validation {
    condition     = !var.enable_private_endpoint || var.subnet_id != null
    error_message = "subnet_id is required when enable_private_endpoint = true."
  }
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = []
  description = "Private DNS zone IDs to link to the private endpoint. AI Foundry typically needs two: privatelink.api.azureml.ms and privatelink.notebooks.azure.net."
}

variable "private_endpoint_name" {
  type        = string
  default     = null
  description = "Override the private endpoint name. Defaults to pep-<name>."
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
      : var.diagnostic_settings.log_analytics_destination_type == null ? true
      : contains(["Dedicated", "AzureDiagnostics"], var.diagnostic_settings.log_analytics_destination_type)
    )
    error_message = "log_analytics_destination_type must be \"Dedicated\" or \"AzureDiagnostics\" when set."
  }
}

# === Optional: Feature Flags ===

variable "enable_public_network_access" {
  type        = bool
  default     = false
  description = "Enable public network access on the hub. Disabled by default for security; set true to allow public access."
}

variable "enable_private_endpoint" {
  type        = bool
  default     = false
  description = "Create a private endpoint to the hub. Requires subnet_id."
}

# === Tags ===

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resources"
}
