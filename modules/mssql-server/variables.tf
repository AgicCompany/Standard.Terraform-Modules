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
  description = "SQL Server name (full CAF-compliant name, provided by consumer)"
}

# === Required: Resource-Specific ===
variable "azuread_administrator" {
  type = object({
    login_username = string
    object_id      = string
  })
  description = "Azure AD administrator configuration"
}

# === Optional: Configuration ===
variable "version_number" {
  type        = string
  default     = "12.0"
  description = "SQL Server version"
}

variable "administrator_login" {
  type        = string
  default     = null
  description = "SQL admin username. Required when enable_aad_only_auth = false."
}

variable "administrator_login_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "SQL admin password. Required when enable_aad_only_auth = false."
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version"

  validation {
    condition     = var.minimum_tls_version == "1.2"
    error_message = "minimum_tls_version must be \"1.2\". TLS 1.0 and 1.1 were retired by Azure on 2025-08-31."
  }
}

variable "connection_policy" {
  type        = string
  default     = "Default"
  description = "Connection policy: Default, Proxy, or Redirect"

  validation {
    condition     = contains(["Default", "Proxy", "Redirect"], var.connection_policy)
    error_message = "Connection policy must be \"Default\", \"Proxy\", or \"Redirect\"."
  }
}

# === Optional: Feature Flags ===
variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Create a private endpoint for this SQL server"
}

variable "enable_public_access" {
  type        = bool
  default     = false
  description = "Allow public network access"
}

variable "enable_outbound_networking_restriction" {
  type        = bool
  default     = false
  description = "Restrict outbound networking access from the SQL server"
}

variable "enable_aad_only_auth" {
  type        = bool
  default     = true
  description = "Restrict authentication to Azure AD only"
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
  description = "Private DNS zone ID for privatelink.database.windows.net. Required when enable_private_endpoint = true."

  validation {
    condition     = var.private_dns_zone_id != null || !var.enable_private_endpoint
    error_message = "private_dns_zone_id is required when enable_private_endpoint is true."
  }
}

# === Optional: Private Endpoint Overrides ===
variable "private_endpoint_name" {
  type        = string
  default     = null
  description = "Override the private endpoint resource name. Defaults to pep-{name}."
}

variable "private_service_connection_name" {
  type        = string
  default     = null
  description = "Override the private service connection name. Defaults to psc-{name}."
}

variable "private_endpoint_nic_name" {
  type        = string
  default     = null
  description = "Override the PE network interface name. Defaults to pep-{name}-nic."
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
