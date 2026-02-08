# === Required ===
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "name" {
  type        = string
  description = "Private DNS zone name (e.g., privatelink.blob.core.windows.net)"
}

# === Optional: Configuration ===
variable "virtual_network_links" {
  type = map(object({
    virtual_network_id   = string
    registration_enabled = optional(bool, false)
  }))
  default     = {}
  description = "Map of virtual network links. Key is used as the link name."
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
