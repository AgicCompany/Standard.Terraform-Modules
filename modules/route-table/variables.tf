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
  description = "Route table name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===

variable "disable_bgp_route_propagation" {
  type        = bool
  default     = false
  description = "Disable BGP route propagation"
}

variable "routes" {
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default     = {}
  description = "Map of routes. Key is used as the route name."

  validation {
    condition = alltrue([
      for k, v in var.routes :
      v.next_hop_type != "VirtualAppliance" || v.next_hop_in_ip_address != null
    ])
    error_message = "next_hop_in_ip_address must be set when next_hop_type is VirtualAppliance."
  }
}

# === Tags ===

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
