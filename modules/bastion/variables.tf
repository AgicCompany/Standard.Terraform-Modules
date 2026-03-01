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
  description = "Azure Bastion host name (full CAF-compliant name, provided by consumer)"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the AzureBastionSubnet (must be named 'AzureBastionSubnet' with minimum /26 CIDR)"
}

# === Optional: Configuration ===

variable "sku" {
  type        = string
  default     = "Basic"
  description = "Bastion host SKU"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "SKU must be Basic or Standard. Developer SKU requires a different deployment model (no Public IP)."
  }
}

variable "copy_paste_enabled" {
  type        = bool
  default     = true
  description = "Enable copy/paste functionality"
}

variable "file_copy_enabled" {
  type        = bool
  default     = false
  description = "Enable file copy (Standard SKU only)"
}

variable "ip_connect_enabled" {
  type        = bool
  default     = false
  description = "Enable IP-based connection (Standard SKU only)"
}

variable "shareable_link_enabled" {
  type        = bool
  default     = false
  description = "Enable shareable links (Standard SKU only)"
}

variable "tunneling_enabled" {
  type        = bool
  default     = false
  description = "Enable native client tunneling (Standard SKU only)"
}

variable "scale_units" {
  type        = number
  default     = 2
  description = "Number of scale units (2-50, Standard SKU only)"

  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "Scale units must be between 2 and 50."
  }
}

# === Tags ===

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
