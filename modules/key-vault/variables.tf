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
  description = "Key Vault name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "sku_name" {
  type        = string
  default     = "standard"
  description = "SKU name (standard or premium)"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU name must be \"standard\" or \"premium\"."
  }
}

variable "tenant_id" {
  type        = string
  default     = null
  description = "Azure AD tenant ID. Defaults to current subscription tenant."
}

variable "soft_delete_retention_days" {
  type        = number
  default     = 90
  description = "Soft delete retention period in days (7-90)"

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90."
  }
}

variable "enabled_for_deployment" {
  type        = bool
  default     = false
  description = "Allow Azure VMs to retrieve certificates stored as secrets"
}

variable "enabled_for_disk_encryption" {
  type        = bool
  default     = false
  description = "Allow Azure Disk Encryption to retrieve secrets and unwrap keys"
}

variable "enabled_for_template_deployment" {
  type        = bool
  default     = false
  description = "Allow Azure Resource Manager to retrieve secrets"
}

variable "network_acls" {
  type = object({
    bypass                     = optional(string, "AzureServices")
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default     = null
  description = "Network ACLs for the Key Vault. Only applies when enable_public_access = true."
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for the Key Vault"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access to the Key Vault"
}

variable "enable_purge_protection" {
  type        = bool
  default     = true
  description = "Enable purge protection. Cannot be disabled once enabled."
}

# === Private Endpoint ===
variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the private endpoint. Required when enable_private_endpoint = true."

  validation {
    condition     = var.subnet_id != null || !var.enable_private_endpoint
    error_message = "subnet_id is required when enable_private_endpoint is true."
  }
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Private DNS zone ID for privatelink.vaultcore.azure.net. Required when enable_private_endpoint = true."

  validation {
    condition     = var.private_dns_zone_id != null || !var.enable_private_endpoint
    error_message = "private_dns_zone_id is required when enable_private_endpoint is true."
  }
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
