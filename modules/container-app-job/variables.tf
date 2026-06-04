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
  description = "Container App Job name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===
variable "container_app_environment_id" {
  type        = string
  description = "Container Apps Environment ID"
}

variable "replica_timeout_in_seconds" {
  type        = number
  description = "Maximum number of seconds a replica is allowed to run. Required by the provider."
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
    command = optional(list(string))
    args    = optional(list(string))
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
variable "workload_profile_name" {
  type        = string
  default     = null
  description = "Workload profile name from the environment. null = Consumption."
}

variable "replica_retry_limit" {
  type        = number
  default     = null
  description = "Maximum number of retries before a replica is considered failed. null = provider default."
}

variable "user_assigned_identity_ids" {
  type        = list(string)
  default     = []
  description = "User Assigned Identity resource IDs to attach to the job."
}

variable "registries" {
  type = list(object({
    server               = string
    identity             = optional(string)
    username             = optional(string)
    password_secret_name = optional(string)
  }))
  default     = []
  description = "Private registry authentication. Each entry requires either 'identity' (resource ID of a user-assigned managed identity) or both 'username' and 'password_secret_name'. The identity should be listed in user_assigned_identity_ids; Azure will reject the deployment if it is not."

  validation {
    condition = alltrue([
      for r in var.registries :
      (r.identity != null) != (r.username != null && r.password_secret_name != null)
    ])
    error_message = "Each registry entry must use either 'identity' or both 'username' and 'password_secret_name', not both methods and not neither."
  }

  validation {
    condition = alltrue([
      for r in var.registries :
      (r.username == null) == (r.password_secret_name == null)
    ])
    error_message = "'username' and 'password_secret_name' must be set together."
  }
}

variable "secrets" {
  type = map(object({
    value               = optional(string)
    key_vault_secret_id = optional(string)
    identity            = optional(string)
  }))
  default     = {}
  sensitive   = true
  description = "Secrets map. Key = secret name. Each entry uses either 'value' (plain string) or 'key_vault_secret_id' (Key Vault reference, optionally with 'identity' for the managed identity to use)."

  validation {
    condition = alltrue([
      for k, v in var.secrets :
      (v.value != null) != (v.key_vault_secret_id != null)
    ])
    error_message = "Each secret must use either 'value' or 'key_vault_secret_id', not both and not neither."
  }
}

variable "init_containers" {
  type = list(object({
    image   = string
    name    = string
    cpu     = optional(number)
    memory  = optional(string)
    command = optional(list(string))
    args    = optional(list(string))
    env = optional(map(object({
      value       = optional(string)
      secret_name = optional(string)
    })), {})
  }))
  default     = []
  description = "Init containers to run before the main container."
}

variable "event_trigger_config" {
  type = object({
    parallelism              = optional(number, 1)
    replica_completion_count = optional(number, 1)
    scale = optional(object({
      min_executions              = optional(number, 0)
      max_executions              = optional(number, 10)
      polling_interval_in_seconds = optional(number, 30)
      rules = optional(list(object({
        name             = string
        custom_rule_type = string
        identity_id      = optional(string)
        metadata         = map(string)
        authentication = optional(list(object({
          secret_name       = string
          trigger_parameter = string
        })), [])
      })), [])
    }), {})
  })
  default     = null
  description = "Event-driven trigger configuration (KEDA). Exactly one trigger type must be set."
}

variable "manual_trigger_config" {
  type = object({
    parallelism              = optional(number, 1)
    replica_completion_count = optional(number, 1)
  })
  default     = null
  description = "Manual trigger configuration. Exactly one trigger type must be set."
}

variable "schedule_trigger_config" {
  type = object({
    cron_expression          = string
    parallelism              = optional(number, 1)
    replica_completion_count = optional(number, 1)
  })
  default     = null
  description = "Schedule (cron) trigger configuration. Exactly one trigger type must be set."
}

# === Optional: Feature Flags ===
variable "enable_system_assigned_identity" {
  type        = bool
  default     = false
  description = "Enable system-assigned managed identity."
}

variable "enable_secret_ignore_changes" {
  type        = bool
  default     = true
  description = "When true, Terraform ignores changes to the secret block after initial creation. Recommended for secrets rotated outside Terraform. WARNING: toggling this value after initial deployment will destroy and recreate the job resource."
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource."
}
