# === Required ===
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "name" {
  type        = string
  description = "Action group name (full CAF-compliant name, provided by consumer)"
}

variable "short_name" {
  type        = string
  description = "Action group short name (max 12 characters, shown in SMS/email)"

  validation {
    condition     = length(var.short_name) >= 1 && length(var.short_name) <= 12
    error_message = "Short name must be between 1 and 12 characters."
  }
}

# === Optional: Configuration ===
variable "email_receivers" {
  type = map(object({
    email_address           = string
    use_common_alert_schema = optional(bool, true)
  }))
  default     = {}
  description = "Map of email receivers. Key is used as the receiver name."
}

variable "sms_receivers" {
  type = map(object({
    country_code = string
    phone_number = string
  }))
  default     = {}
  description = "Map of SMS receivers. Key is used as the receiver name."
}

variable "webhook_receivers" {
  type = map(object({
    service_uri             = string
    use_common_alert_schema = optional(bool, true)
    aad_auth = optional(object({
      object_id = string
      tenant_id = optional(string)
    }))
  }))
  default     = {}
  description = "Map of webhook receivers. Key is used as the receiver name."
}

variable "azure_app_push_receivers" {
  type = map(object({
    email_address = string
  }))
  default     = {}
  description = "Map of Azure app push receivers. Key is used as the receiver name."
}

# === Optional: Feature Flags ===
variable "enabled" {
  type        = bool
  default     = true
  description = "Whether the action group is enabled"
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
