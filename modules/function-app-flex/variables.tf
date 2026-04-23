# === Required ===
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "name" {
  type        = string
  description = "Name of the Function App (full CAF-compliant name, provided by consumer)."
}

# === Required: Resource-Specific ===
variable "service_plan_id" {
  type        = string
  description = "ID of the FC1 (sku_name = FC1) App Service Plan."
}

variable "runtime_name" {
  type        = string
  description = "Runtime stack: dotnet-isolated, python, node, java, powershell, or custom."

  validation {
    condition     = contains(["dotnet-isolated", "python", "node", "java", "powershell", "custom"], var.runtime_name)
    error_message = "runtime_name must be one of: dotnet-isolated, python, node, java, powershell, custom."
  }
}

variable "runtime_version" {
  type        = string
  description = "Runtime version (e.g. '8.0' for dotnet-isolated, '3.11' for python)."
}

variable "storage_container_endpoint" {
  type        = string
  description = "URL of the blob container for deployment package storage."
}

# === Optional: Configuration ===
variable "instance_memory_in_mb" {
  type        = number
  default     = 2048
  description = "Memory per instance in MB."

  validation {
    condition     = contains([512, 2048, 4096], var.instance_memory_in_mb)
    error_message = "Allowed values: 512, 2048, 4096."
  }
}

variable "maximum_instance_count" {
  type        = number
  default     = 10
  description = "Maximum number of instances for scaling."
}

variable "always_ready_instances" {
  type = map(object({
    instance_count = number
  }))
  default     = {}
  description = "Map of always-ready instance configurations keyed by function name."
}

variable "storage_container_type" {
  type        = string
  default     = "blobContainer"
  description = "Storage container type for FC1 deployment package."
}

variable "storage_authentication_type" {
  type        = string
  default     = "StorageAccountConnectionString"
  description = "Storage auth type: StorageAccountConnectionString, SystemAssignedIdentity, or UserAssignedIdentity."

  validation {
    condition     = contains(["StorageAccountConnectionString", "SystemAssignedIdentity", "UserAssignedIdentity"], var.storage_authentication_type)
    error_message = "Must be StorageAccountConnectionString, SystemAssignedIdentity, or UserAssignedIdentity."
  }
}

variable "storage_user_assigned_identity_id" {
  type        = string
  default     = null
  description = "Resource ID of the user-assigned identity for storage auth. Required when storage_authentication_type = UserAssignedIdentity."
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = "Application settings. Ignored on subsequent applies (managed by dev teams via CI/CD)."
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for VNet integration (outbound traffic)."
}

# === Optional: Identity ===
variable "identity_type" {
  type        = string
  default     = "None"
  description = "Managed identity type: None, SystemAssigned, or UserAssigned."

  validation {
    condition     = contains(["None", "SystemAssigned", "UserAssigned"], var.identity_type)
    error_message = "Must be None, SystemAssigned, or UserAssigned."
  }
}

variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "List of user-assigned identity resource IDs. Required when identity_type = UserAssigned."
}

# === Optional: Security ===
variable "https_only" {
  type        = bool
  default     = true
  description = "Require HTTPS connections."
}

variable "client_certificate_mode" {
  type        = string
  default     = "Required"
  description = "Client certificate mode: Required, Optional, or OptionalInteractiveUser."

  validation {
    condition     = contains(["Required", "Optional", "OptionalInteractiveUser"], var.client_certificate_mode)
    error_message = "Must be Required, Optional, or OptionalInteractiveUser."
  }
}

variable "webdeploy_publish_basic_authentication_enabled" {
  type        = bool
  default     = false
  description = "Enable basic authentication for web deploy."
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for the Function App."
}

# === Optional: Private Endpoint ===
variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the private endpoint. Required when enable_private_endpoint = true."
}

variable "private_dns_zone_ids" {
  type        = list(string)
  default     = []
  description = "Private DNS zone IDs for the PE DNS zone group."
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
  description = "Tags to apply to all resources."
}
