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
  description = "VM size (e.g., Standard_B2s, Standard_D2s_v5)"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the network interface"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Admin password for the VM. Must meet Azure complexity requirements."
}

# === Optional: Configuration ===
variable "computer_name" {
  type        = string
  default     = null
  description = "Windows computer name (max 15 characters). Defaults to var.name truncated to 15 characters."
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
  description = "Source image reference. Defaults to Windows Server 2022 Datacenter Gen2."
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
  description = "Base64-encoded custom data to pass to the VM"
}

variable "license_type" {
  type        = string
  default     = null
  description = "License type for Azure Hybrid Benefit: None or Windows_Server"

  validation {
    condition     = var.license_type == null || contains(["None", "Windows_Server"], var.license_type)
    error_message = "license_type must be null, \"None\", or \"Windows_Server\"."
  }
}

variable "timezone" {
  type        = string
  default     = null
  description = "Timezone for the VM (e.g., \"W. Europe Standard Time\")"
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

variable "enable_encryption_at_host" {
  type        = bool
  default     = true
  description = "Enable encryption at host (encrypts temp disks and cached data at rest). Requires Microsoft.Compute/EncryptionAtHost feature registered on the subscription."
}

variable "enable_secure_boot" {
  type        = bool
  default     = true
  description = "Enable Secure Boot (Trusted Launch). Requires Gen2 VM image."
}

variable "enable_vtpm" {
  type        = bool
  default     = true
  description = "Enable vTPM (Trusted Launch). Requires Gen2 VM image."
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
