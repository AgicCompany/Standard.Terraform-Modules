# === Required ===
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "name" {
  type        = string
  description = "Container App name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===
variable "container_app_environment_id" {
  type        = string
  description = "Container Apps Environment ID"
}

variable "container" {
  type = object({
    image  = string
    cpu    = number
    memory = string
    env = optional(map(object({
      value       = optional(string)
      secret_name = optional(string)
    })), {})
    liveness_probe = optional(object({
      transport               = string
      port                    = number
      path                    = optional(string)
      initial_delay           = optional(number, 1)
      interval_seconds        = optional(number, 10)
      failure_count_threshold = optional(number, 3)
    }))
    readiness_probe = optional(object({
      transport               = string
      port                    = number
      path                    = optional(string)
      initial_delay           = optional(number, 1)
      interval_seconds        = optional(number, 10)
      failure_count_threshold = optional(number, 3)
    }))
    startup_probe = optional(object({
      transport               = string
      port                    = number
      path                    = optional(string)
      initial_delay           = optional(number, 1)
      interval_seconds        = optional(number, 10)
      failure_count_threshold = optional(number, 3)
    }))
  })
  description = "Main container configuration"
}

# === Optional: Configuration ===
variable "revision_mode" {
  type        = string
  default     = "Single"
  description = "Revision mode: Single or Multiple"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be \"Single\" or \"Multiple\"."
  }
}

variable "ingress" {
  type = object({
    target_port = number
    transport   = optional(string, "auto")
    traffic_weight = optional(object({
      latest_revision = optional(bool, true)
      percentage      = optional(number, 100)
    }), {})
  })
  default     = null
  description = "Ingress configuration. Only used when enable_ingress = true."

  validation {
    condition     = var.ingress == null || contains(["auto", "http", "http2", "tcp"], var.ingress.transport)
    error_message = "ingress.transport must be \"auto\", \"http\", \"http2\", or \"tcp\"."
  }
}

variable "secrets" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = "Secrets. Key = secret name, value = secret value."
}

variable "scale" {
  type = object({
    min_replicas = optional(number, 0)
    max_replicas = optional(number, 10)
    rules = optional(list(object({
      name = string
      http_scale_rule = optional(object({
        concurrent_requests = string
      }))
    })), [])
  })
  default     = {}
  description = "Scale configuration. Defaults to 0-10 replicas."
}

variable "user_assigned_identity_ids" {
  type        = list(string)
  default     = []
  description = "User Assigned Identity IDs"
}

variable "workload_profile_name" {
  type        = string
  default     = null
  description = "Workload profile name from the environment. null = Consumption."
}

variable "init_containers" {
  type = list(object({
    image  = string
    name   = string
    cpu    = optional(number)
    memory = optional(string)
    env = optional(map(object({
      value       = optional(string)
      secret_name = optional(string)
    })), {})
    command = optional(list(string))
    args    = optional(list(string))
  }))
  default     = []
  description = "Init containers to run before the main container"
}

# === Optional: Feature Flags ===
variable "enable_ingress" {
  type        = bool
  default     = false
  description = "Enable HTTP/TCP ingress. Requires ingress variable to be set."

  validation {
    condition     = !var.enable_ingress || var.ingress != null
    error_message = "The ingress variable must be set when enable_ingress is true."
  }
}

variable "enable_external_ingress" {
  type        = bool
  default     = false
  description = "Allow ingress from outside the Container Apps Environment"
}

variable "enable_system_assigned_identity" {
  type        = bool
  default     = false
  description = "Enable system-assigned managed identity"
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
