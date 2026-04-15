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
  description = "Storage account name (full CAF-compliant name, provided by consumer)"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 characters, lowercase letters and numbers only."
  }
}

# === Optional: Configuration ===
variable "account_tier" {
  type        = string
  default     = "Standard"
  description = "Account tier (Standard or Premium)"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier must be one of: Standard, Premium."
  }
}

variable "account_replication_type" {
  type        = string
  default     = "LRS"
  description = "Replication type (LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS)"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of: LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  type        = string
  default     = "StorageV2"
  description = "Account kind (StorageV2, BlobStorage, BlockBlobStorage, FileStorage)"

  validation {
    condition     = contains(["StorageV2", "BlobStorage", "BlockBlobStorage", "FileStorage", "Storage"], var.account_kind)
    error_message = "account_kind must be one of: StorageV2, BlobStorage, BlockBlobStorage, FileStorage, Storage."
  }
}

variable "access_tier" {
  type        = string
  default     = "Hot"
  description = "Access tier for BlobStorage/StorageV2 (Hot, Cool, or Cold)"

  validation {
    condition     = contains(["Hot", "Cool", "Cold"], var.access_tier)
    error_message = "access_tier must be one of: Hot, Cool, Cold."
  }
}

variable "min_tls_version" {
  type        = string
  default     = "TLS1_2"
  description = "Minimum TLS version"

  validation {
    condition     = var.min_tls_version == "TLS1_2"
    error_message = "min_tls_version must be \"TLS1_2\". TLS 1.0 and 1.1 were retired by Azure on 2026-02-03."
  }
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  default     = false
  description = "Allow blob public access at the container level"
}

variable "shared_access_key_enabled" {
  type        = bool
  default     = false
  description = "Enable shared key authorization. Disabled by default; use managed identity where possible."
}

variable "blob_soft_delete_retention_days" {
  type        = number
  default     = 7
  description = "Blob soft delete retention period in days (1-365)"

  validation {
    condition     = var.blob_soft_delete_retention_days >= 1 && var.blob_soft_delete_retention_days <= 365
    error_message = "Blob soft delete retention days must be between 1 and 365."
  }
}

variable "container_soft_delete_retention_days" {
  type        = number
  default     = 7
  description = "Container soft delete retention period in days (1-365)"

  validation {
    condition     = var.container_soft_delete_retention_days >= 1 && var.container_soft_delete_retention_days <= 365
    error_message = "Container soft delete retention days must be between 1 and 365."
  }
}

variable "network_rules" {
  type = object({
    bypass                     = optional(list(string), ["AzureServices"])
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default     = null
  description = "Network rules for the storage account. Only applies when enable_public_access = true."
}

# === Optional: Feature Flags ===
variable "enable_private_endpoints" {
  type        = bool
  default     = true
  description = "Create private endpoints for enabled subresources"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access to the storage account"
}

variable "enable_blob_private_endpoint" {
  type        = bool
  default     = true
  description = "Create private endpoint for blob subresource"
}

variable "enable_file_private_endpoint" {
  type        = bool
  default     = false
  description = "Create private endpoint for file subresource"
}

variable "enable_table_private_endpoint" {
  type        = bool
  default     = false
  description = "Create private endpoint for table subresource"
}

variable "enable_queue_private_endpoint" {
  type        = bool
  default     = false
  description = "Create private endpoint for queue subresource"
}

variable "enable_versioning" {
  type        = bool
  default     = false
  description = "Enable blob versioning"
}

variable "enable_blob_soft_delete" {
  type        = bool
  default     = true
  description = "Enable blob soft delete"
}

variable "enable_container_soft_delete" {
  type        = bool
  default     = true
  description = "Enable container soft delete"
}

# === Private Endpoint ===
variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for private endpoints. Required when any private endpoint is enabled."
}

variable "private_dns_zone_ids" {
  type        = map(string)
  default     = {}
  description = "Map of subresource name (blob, file, table, queue) to private DNS zone ID."

  validation {
    condition     = alltrue([for k in keys(var.private_dns_zone_ids) : contains(["blob", "file", "table", "queue"], k)])
    error_message = "private_dns_zone_ids keys must be a subset of: blob, file, table, queue."
  }
}

# === Optional: Private Endpoint Overrides ===
variable "private_endpoint_names" {
  type        = map(string)
  default     = {}
  description = "Override PE names per subresource key (blob, file, table, queue). Defaults to pep-{name}-{subresource}."

  validation {
    condition     = alltrue([for k in keys(var.private_endpoint_names) : contains(["blob", "file", "table", "queue"], k)])
    error_message = "private_endpoint_names keys must be a subset of: blob, file, table, queue."
  }
}

variable "private_service_connection_names" {
  type        = map(string)
  default     = {}
  description = "Override PSC names per subresource key. Defaults to psc-{name}-{subresource}."

  validation {
    condition     = alltrue([for k in keys(var.private_service_connection_names) : contains(["blob", "file", "table", "queue"], k)])
    error_message = "private_service_connection_names keys must be a subset of: blob, file, table, queue."
  }
}

variable "private_endpoint_nic_names" {
  type        = map(string)
  default     = {}
  description = "Override PE NIC names per subresource key. Defaults to pep-{name}-{subresource}-nic."

  validation {
    condition     = alltrue([for k in keys(var.private_endpoint_nic_names) : contains(["blob", "file", "table", "queue"], k)])
    error_message = "private_endpoint_nic_names keys must be a subset of: blob, file, table, queue."
  }
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
