# === Required ===
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "name" {
  type        = string
  description = "Front Door profile name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "sku_name" {
  type        = string
  default     = "Standard_AzureFrontDoor"
  description = "SKU: Standard_AzureFrontDoor or Premium_AzureFrontDoor"

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.sku_name)
    error_message = "sku_name must be \"Standard_AzureFrontDoor\" or \"Premium_AzureFrontDoor\"."
  }
}

variable "response_timeout_seconds" {
  type        = number
  default     = 60
  description = "Response timeout in seconds (16-240)"

  validation {
    condition     = var.response_timeout_seconds >= 16 && var.response_timeout_seconds <= 240
    error_message = "response_timeout_seconds must be between 16 and 240."
  }
}

variable "endpoints" {
  type = map(object({
    enabled = optional(bool, true)
  }))
  default     = {}
  description = "Map of Front Door endpoints. Key is used as the endpoint name."
}

variable "origin_groups" {
  type = map(object({
    session_affinity_enabled                                  = optional(bool, false)
    restore_traffic_time_to_healed_or_new_endpoint_in_minutes = optional(number, 10)
    health_probe = optional(object({
      interval_in_seconds = optional(number, 100)
      path                = optional(string, "/")
      protocol            = optional(string, "Https")
      request_type        = optional(string, "HEAD")
    }))
    load_balancing = optional(object({
      additional_latency_in_milliseconds = optional(number, 50)
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
    }), {})
  }))
  default     = {}
  description = "Map of origin groups with health probe and load balancing settings."
}

variable "origins" {
  type = map(object({
    origin_group_name              = string
    host_name                      = string
    origin_host_header             = optional(string)
    http_port                      = optional(number, 80)
    https_port                     = optional(number, 443)
    priority                       = optional(number, 1)
    weight                         = optional(number, 1000)
    certificate_name_check_enabled = optional(bool, true)
    enabled                        = optional(bool, true)
  }))
  default     = {}
  description = "Map of origins. Each origin references an origin_group by key name."
}

variable "routes" {
  type = map(object({
    endpoint_name          = string
    origin_group_name      = string
    origin_names           = optional(list(string))
    patterns_to_match      = optional(list(string), ["/*"])
    supported_protocols    = optional(list(string), ["Http", "Https"])
    forwarding_protocol    = optional(string, "HttpsOnly")
    https_redirect_enabled = optional(bool, true)
    link_to_default_domain = optional(bool, true)
    enabled                = optional(bool, true)
  }))
  default     = {}
  description = "Map of routes. Each route references an endpoint and origin_group by key name."
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
