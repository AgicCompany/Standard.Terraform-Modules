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
  description = "Virtual machine name (full CAF-compliant name, provided by consumer)"
}

variable "size" {
  type        = string
  description = "VM size (e.g., Standard_B1s, Standard_D2s_v5)"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the network interface"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key for admin user authentication"
}

# === Optional: Configuration ===
variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  description = "Source image reference. Defaults to Ubuntu 22.04 LTS Gen2."
}

variable "os_disk" {
  type = object({
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "Premium_LRS")
    disk_size_gb         = optional(number)
  })
  default     = {}
  description = "OS disk configuration"
}

variable "data_disks" {
  type = map(object({
    lun                  = number
    disk_size_gb         = number
    storage_account_type = optional(string, "Premium_LRS")
    caching              = optional(string, "ReadOnly")
  }))
  default     = {}
  description = "Map of data disks to attach. Key is used as disk name suffix."
}

variable "private_ip_address_allocation" {
  type        = string
  default     = "Dynamic"
  description = "Private IP allocation method: Dynamic or Static"

  validation {
    condition     = contains(["Dynamic", "Static"], var.private_ip_address_allocation)
    error_message = "private_ip_address_allocation must be \"Dynamic\" or \"Static\"."
  }
}

variable "private_ip_address" {
  type        = string
  default     = null
  description = "Static private IP address. Required when private_ip_address_allocation = Static."
}

variable "zone" {
  type        = string
  default     = null
  description = "Availability zone (1, 2, or 3)"
}

variable "custom_data" {
  type        = string
  default     = null
  sensitive   = true
  description = "Base64-encoded custom data (cloud-init) to pass to the VM"
}

variable "user_assigned_identity_ids" {
  type        = list(string)
  default     = []
  description = "List of user-assigned managed identity IDs"
}

variable "boot_diagnostics_storage_uri" {
  type        = string
  default     = null
  description = "Storage account URI for boot diagnostics. If null with boot diagnostics enabled, uses managed storage."
}

# === Optional: Feature Flags ===
variable "enable_boot_diagnostics" {
  type        = bool
  default     = false
  description = "Enable boot diagnostics"
}

variable "enable_system_assigned_identity" {
  type        = bool
  default     = false
  description = "Enable system-assigned managed identity"
}

variable "enable_public_ip" {
  type        = bool
  default     = false
  description = "Create and attach a public IP address"
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
