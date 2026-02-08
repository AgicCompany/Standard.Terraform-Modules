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
  description = "Network security group name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "security_rules" {
  type = map(object({
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    source_port_range                          = optional(string, "*")
    destination_port_range                     = optional(string, null)
    source_port_ranges                         = optional(list(string), null)
    destination_port_ranges                    = optional(list(string), null)
    source_address_prefix                      = optional(string, null)
    destination_address_prefix                 = optional(string, null)
    source_address_prefixes                    = optional(list(string), null)
    destination_address_prefixes               = optional(list(string), null)
    source_application_security_group_ids      = optional(list(string), null)
    destination_application_security_group_ids = optional(list(string), null)
    description                                = optional(string, "")
  }))
  default     = {}
  description = "Map of security rules. Key is used as the rule name."
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
