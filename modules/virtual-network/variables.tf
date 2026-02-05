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
  description = "Virtual network name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===
variable "address_space" {
  type        = list(string)
  description = "Address space for the virtual network (e.g., [\"10.0.0.0/16\"])"
}

# === Optional: Configuration ===
variable "subnets" {
  type = map(object({
    address_prefixes                              = list(string)
    network_security_group_id                     = optional(string, null)
    route_table_id                                = optional(string, null)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, false)
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }), null)
  }))
  default     = {}
  description = "Map of subnets. Key is used as the subnet name."
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resources"
}
