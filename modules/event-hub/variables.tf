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
  description = "Event Hub namespace name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "sku" {
  type        = string
  default     = "Standard"
  description = "Event Hub namespace SKU"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be \"Basic\", \"Standard\", or \"Premium\"."
  }
}

variable "capacity" {
  type        = number
  default     = 1
  description = "Throughput units (Basic/Standard: 1-40, Premium: 1-16)"
}

variable "min_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version. Only \"1.2\" is supported; TLS 1.0/1.1 retired by Azure."

  validation {
    condition     = contains(["1.2"], var.min_tls_version)
    error_message = "Only TLS 1.2 is supported; TLS 1.0 and 1.1 were retired by Azure on 2024-10-31."
  }
}

variable "auto_inflate_enabled" {
  type        = bool
  default     = false
  description = "Enable auto-inflate for throughput units (Standard/Premium only)"
}

variable "maximum_throughput_units" {
  type        = number
  default     = null
  description = "Maximum throughput units when auto-inflate is enabled (1-40)"
}

variable "event_hubs" {
  type = map(object({
    partition_count   = optional(number, 2)
    message_retention = optional(number, 1)
    consumer_groups = optional(map(object({
      user_metadata = optional(string)
    })), {})
  }))
  default     = {}
  description = "Map of Event Hubs to create within the namespace"
}

variable "authorization_rules" {
  type = map(object({
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
  }))
  default     = {}
  description = "Map of namespace-level authorization rules"
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for this Event Hub namespace"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access"
}

variable "enable_local_auth" {
  type        = bool
  default     = false
  description = "Enable local (SAS key) authentication. Secure default: disabled."
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

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
