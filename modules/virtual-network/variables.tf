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

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space CIDR must be provided."
  }
}

# === Optional: Configuration ===
variable "subnets" {
  type = map(object({
    address_prefixes                              = list(string)
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

  validation {
    condition = alltrue([
      for k, v in var.subnets :
      contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], v.private_endpoint_network_policies)
    ])
    error_message = "private_endpoint_network_policies must be one of: Disabled, Enabled, NetworkSecurityGroupEnabled, RouteTableEnabled."
  }
}

variable "subnet_nsg_associations" {
  type        = map(string)
  default     = {}
  description = "Map of subnet name to NSG resource ID. Keys must match keys in the subnets variable."
}

variable "subnet_route_table_associations" {
  type        = map(string)
  default     = {}
  description = "Map of subnet name to route table resource ID. Keys must match keys in the subnets variable."
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
