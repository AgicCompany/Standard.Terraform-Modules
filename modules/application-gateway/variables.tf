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
  description = "Application Gateway name (full CAF-compliant name, provided by consumer)"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the Application Gateway (dedicated subnet, minimum /24 recommended)"
}

# === Optional: Configuration ===
variable "sku_name" {
  type        = string
  default     = "Standard_v2"
  description = "SKU name for the Application Gateway"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "SKU must be Standard_v2 or WAF_v2."
  }
}

variable "sku_tier" {
  type        = string
  default     = "Standard_v2"
  description = "SKU tier for the Application Gateway"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_tier)
    error_message = "SKU tier must be Standard_v2 or WAF_v2."
  }
}

variable "autoscale" {
  type = object({
    min_capacity = number
    max_capacity = optional(number)
  })
  default = {
    min_capacity = 1
    max_capacity = 2
  }
  description = "Autoscale configuration (min 0-100, max 2-125)"
}

variable "zones" {
  type        = list(string)
  default     = []
  description = "Availability zones"
}

variable "firewall_policy_id" {
  type        = string
  default     = null
  description = "WAF policy resource ID (for WAF_v2 SKU)"
}

variable "frontend_ports" {
  type = map(object({
    port = number
  }))
  default = {
    http = {
      port = 80
    }
    https = {
      port = 443
    }
  }
  description = "Map of frontend ports. Key is used as the port name."
}

variable "backend_address_pools" {
  type = map(object({
    fqdns        = optional(list(string), [])
    ip_addresses = optional(list(string), [])
  }))
  default     = {}
  description = "Map of backend address pools. Key is used as the pool name."
}

variable "backend_http_settings" {
  type = map(object({
    port                                      = number
    protocol                                  = string
    cookie_based_affinity                     = optional(string, "Disabled")
    request_timeout                           = optional(number, 30)
    probe_name                                = optional(string, null)
    host_name                                 = optional(string, null)
    pick_host_name_from_backend_http_settings = optional(bool, false)
    path                                      = optional(string, null)
  }))
  default     = {}
  description = "Map of backend HTTP settings. Key is used as the setting name."
}

variable "http_listeners" {
  type = map(object({
    frontend_port_name   = string
    protocol             = string
    host_name            = optional(string, null)
    host_names           = optional(list(string), null)
    ssl_certificate_name = optional(string, null)
  }))
  default     = {}
  description = "Map of HTTP listeners. Key is used as the listener name."
}

variable "request_routing_rules" {
  type = map(object({
    rule_type                   = optional(string, "Basic")
    priority                    = number
    http_listener_name          = string
    backend_address_pool_name   = optional(string, null)
    backend_http_settings_name  = optional(string, null)
    url_path_map_name           = optional(string, null)
    redirect_configuration_name = optional(string, null)
  }))
  default     = {}
  description = "Map of request routing rules. Key is used as the rule name."
}

variable "probes" {
  type = map(object({
    protocol                                  = string
    path                                      = string
    host                                      = optional(string, null)
    interval                                  = optional(number, 30)
    timeout                                   = optional(number, 30)
    unhealthy_threshold                       = optional(number, 3)
    pick_host_name_from_backend_http_settings = optional(bool, false)
    minimum_servers                           = optional(number, 0)
    match_status_codes                        = optional(list(string), ["200-399"])
  }))
  default     = {}
  description = "Map of health probes. Key is used as the probe name."
}

variable "ssl_certificates" {
  type = map(object({
    data                = optional(string, null)
    password            = optional(string, null)
    key_vault_secret_id = optional(string, null)
  }))
  default     = {}
  sensitive   = true
  description = "Map of SSL certificates. Key is used as the certificate name. Provide either data+password (PFX) or key_vault_secret_id."
}

variable "redirect_configurations" {
  type = map(object({
    redirect_type        = string
    target_listener_name = optional(string, null)
    target_url           = optional(string, null)
    include_path         = optional(bool, true)
    include_query_string = optional(bool, true)
  }))
  default     = {}
  description = "Map of redirect configurations. Key is used as the configuration name."
}

variable "url_path_maps" {
  type = map(object({
    default_backend_address_pool_name   = optional(string, null)
    default_backend_http_settings_name  = optional(string, null)
    default_redirect_configuration_name = optional(string, null)
    path_rules = map(object({
      paths                       = list(string)
      backend_address_pool_name   = optional(string, null)
      backend_http_settings_name  = optional(string, null)
      redirect_configuration_name = optional(string, null)
    }))
  }))
  default     = {}
  description = "Map of URL path maps. Key is used as the path map name."
}

variable "enable_http2" {
  type        = bool
  default     = true
  description = "Enable HTTP/2"
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
