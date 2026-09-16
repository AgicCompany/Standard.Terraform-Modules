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
  description = "SQL Managed Instance name (full CAF-compliant name, provided by consumer). Must be globally unique."
}

# === Required: Resource-Specific ===
variable "subnet_id" {
  type        = string
  description = "ID of the subnet hosting the instance. Must be dedicated to SQL MI, delegated to Microsoft.Sql/managedInstances, and have a network security group and route table associated (consumer responsibility)."
}

variable "sku_name" {
  type        = string
  description = "Service tier and hardware generation. No default: sizing an instance that takes hours to (re)provision must be an explicit choice."

  validation {
    condition     = contains(["GP_Gen5", "GP_Gen8IM", "GP_Gen8IH", "BC_Gen5", "BC_Gen8IM", "BC_Gen8IH"], var.sku_name)
    error_message = "sku_name must be one of GP_Gen5, GP_Gen8IM, GP_Gen8IH, BC_Gen5, BC_Gen8IM, BC_Gen8IH (Gen4 hardware is retired)."
  }
}

variable "vcores" {
  type        = number
  description = "Number of vCores. No default (see sku_name)."

  validation {
    condition     = contains([4, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 56, 64, 80, 96, 128], var.vcores)
    error_message = "vcores must be one of 4, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 56, 64, 80, 96, 128."
  }
}

variable "storage_size_in_gb" {
  type        = number
  description = "Maximum storage in GB. Must be a multiple of 32. No default (see sku_name)."

  validation {
    condition     = var.storage_size_in_gb >= 32 && var.storage_size_in_gb % 32 == 0
    error_message = "storage_size_in_gb must be a multiple of 32 (minimum 32)."
  }
}

variable "azuread_administrator" {
  type = object({
    login_username = string
    object_id      = string
    principal_type = string
    tenant_id      = optional(string)
  })
  description = "Microsoft Entra ID administrator. principal_type must be User, Group, or Application. tenant_id only when the administrator is homed in another tenant."

  validation {
    condition     = contains(["User", "Group", "Application"], var.azuread_administrator.principal_type)
    error_message = "azuread_administrator.principal_type must be \"User\", \"Group\", or \"Application\"."
  }
}

# === Optional: Configuration ===
variable "license_type" {
  type        = string
  default     = "LicenseIncluded"
  description = "License model: LicenseIncluded (pay-as-you-go) or BasePrice (Azure Hybrid Benefit, requires existing SQL Server licenses with Software Assurance)."

  validation {
    condition     = contains(["LicenseIncluded", "BasePrice"], var.license_type)
    error_message = "license_type must be \"LicenseIncluded\" or \"BasePrice\"."
  }
}

variable "administrator_login" {
  type        = string
  default     = null
  description = "SQL admin username. Required when enable_aad_only_auth = false. Changing it forces a new instance."
}

variable "administrator_login_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "SQL admin password. Required when enable_aad_only_auth = false. When non-null: min 12 chars; must include upper, lower, digit, and symbol."

  validation {
    condition = (
      var.administrator_login_password == null ? true
      : (
        length(var.administrator_login_password) >= 12
        && can(regex("[A-Z]", var.administrator_login_password))
        && can(regex("[a-z]", var.administrator_login_password))
        && can(regex("[0-9]", var.administrator_login_password))
        && can(regex("[^A-Za-z0-9]", var.administrator_login_password))
      )
    )
    error_message = "When provided, password must be at least 12 characters and include upper, lower, digit, and symbol."
  }
}

variable "collation" {
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
  description = "Instance collation. Changing it forces a new instance."
}

variable "timezone_id" {
  type        = string
  default     = "UTC"
  description = "Windows time zone ID the instance operates in (e.g. \"W. Europe Standard Time\"). Changing it forces a new instance."
}

variable "database_format" {
  type        = string
  default     = "SQLServer2022"
  description = "Internal database format tied to the SQL engine version: SQLServer2022 or AlwaysUpToDate."

  validation {
    condition     = contains(["SQLServer2022", "AlwaysUpToDate"], var.database_format)
    error_message = "database_format must be \"SQLServer2022\" or \"AlwaysUpToDate\"."
  }
}

variable "maintenance_configuration_name" {
  type        = string
  default     = "SQL_Default"
  description = "Public maintenance configuration window: SQL_Default or SQL_{Location}_MI_{1|2} (e.g. SQL_WestEurope_MI_1)."
}

variable "storage_account_type" {
  type        = string
  default     = "GRS"
  description = "Backup storage redundancy: GRS, GZRS, LRS, or ZRS."

  validation {
    condition     = contains(["GRS", "GZRS", "LRS", "ZRS"], var.storage_account_type)
    error_message = "storage_account_type must be one of GRS, GZRS, LRS, ZRS."
  }
}

variable "hybrid_secondary_usage" {
  type        = string
  default     = "Active"
  description = "Hybrid secondary usage for DR: Active or Passive (Passive is license-free for a failover-group secondary with Azure Hybrid Benefit)."

  validation {
    condition     = contains(["Active", "Passive"], var.hybrid_secondary_usage)
    error_message = "hybrid_secondary_usage must be \"Active\" or \"Passive\"."
  }
}

variable "proxy_override" {
  type        = string
  default     = "Default"
  description = "Connection type: Default, Proxy, or Redirect."

  validation {
    condition     = contains(["Default", "Proxy", "Redirect"], var.proxy_override)
    error_message = "proxy_override must be \"Default\", \"Proxy\", or \"Redirect\"."
  }
}

variable "dns_zone_partner_id" {
  type        = string
  default     = null
  description = "ID of another SQL Managed Instance whose DNS zone this instance shares (prerequisite for a failover group). Set at creation only."
}

variable "min_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version. Only \"1.2\" is supported; TLS 1.0/1.1 retired by Azure."

  validation {
    condition     = contains(["1.2"], var.min_tls_version)
    error_message = "Only TLS 1.2 is supported; TLS 1.0 and 1.1 were retired by Azure on 2025-08-31."
  }
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default     = { type = "SystemAssigned" }
  description = "Managed identity. type must be \"SystemAssigned\", \"UserAssigned\", or \"SystemAssigned, UserAssigned\". identity_ids is required (non-empty) iff type includes UserAssigned. An identity is required for Entra authentication and customer-managed TDE keys."

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "identity.type must be \"SystemAssigned\", \"UserAssigned\", or \"SystemAssigned, UserAssigned\"."
  }
}

variable "customer_managed_key" {
  type = object({
    key_vault_key_id      = string
    auto_rotation_enabled = optional(bool, false)
  })
  default     = null
  description = "Customer-managed TDE protector key in Azure Key Vault. null = service-managed key. The instance identity needs Get, WrapKey and UnwrapKey on the key. Use a versioned key ID unless auto_rotation_enabled = true."
}

variable "security_alert_policy" {
  type = object({
    email_addresses              = optional(list(string), [])
    email_account_admins_enabled = optional(bool, false)
    disabled_alerts              = optional(list(string), [])
    retention_days               = optional(number, 0)
  })
  default     = {}
  description = "Advanced Threat Protection settings, applied when enable_security_alert_policy = true. disabled_alerts values: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action, Brute_Force."

  validation {
    condition = alltrue([
      for a in var.security_alert_policy.disabled_alerts :
      contains(["Sql_Injection", "Sql_Injection_Vulnerability", "Access_Anomaly", "Data_Exfiltration", "Unsafe_Action", "Brute_Force"], a)
    ])
    error_message = "security_alert_policy.disabled_alerts may only contain Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action, Brute_Force."
  }
}

variable "timeouts" {
  type = object({
    create = optional(string, "24h")
    update = optional(string, "24h")
    delete = optional(string, "24h")
  })
  default     = {}
  description = "Operation timeouts for the instance. Provisioning a SQL Managed Instance can take several hours; the provider defaults (24h) are kept unless overridden."
}

# === Optional: Feature Flags ===
variable "enable_aad_only_auth" {
  type        = bool
  default     = true
  description = "Restrict authentication to Microsoft Entra ID only. When false, administrator_login and administrator_login_password are required."
}

variable "enable_public_data_endpoint" {
  type        = bool
  default     = false
  description = "Enable the public data endpoint (TCP 3342). Disabled by default."
}

variable "enable_zone_redundancy" {
  type        = bool
  default     = false
  description = "Deploy the instance across availability zones (extra cost)."
}

variable "enable_general_purpose_v2" {
  type        = bool
  default     = false
  description = "Use the next-gen General Purpose service tier (GP SKUs only)."
}

variable "enable_security_alert_policy" {
  type        = bool
  default     = true
  description = "Enable Advanced Threat Protection (security alert policy) on the instance."
}

# === Optional: Diagnostics ===
variable "diagnostic_settings" {
  type = object({
    name                           = optional(string)
    log_analytics_workspace_id     = optional(string)
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
    log_analytics_destination_type = optional(string)
    enabled_log_categories         = optional(list(string))
    enabled_metrics                = optional(list(string))
  })
  default     = null
  description = "Optional diagnostic settings. null disables. Supports multi-sink (Log Analytics, storage account, Event Hub). enabled_log_categories = null -> all categories the resource supports. enabled_metrics = null -> all metrics the resource supports. At least one of log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id is required when the object is non-null."

  validation {
    condition = (
      var.diagnostic_settings == null ? true
      : (var.diagnostic_settings.log_analytics_workspace_id != null
        || var.diagnostic_settings.storage_account_id != null
      || var.diagnostic_settings.eventhub_authorization_rule_id != null)
    )
    error_message = "At least one destination (log_analytics_workspace_id, storage_account_id, or eventhub_authorization_rule_id) is required when diagnostic_settings is set."
  }

  validation {
    condition = (
      var.diagnostic_settings == null ? true
      : (
        var.diagnostic_settings.log_analytics_destination_type == null ? true
        : contains(["Dedicated", "AzureDiagnostics"], var.diagnostic_settings.log_analytics_destination_type)
      )
    )
    error_message = "log_analytics_destination_type must be \"Dedicated\" or \"AzureDiagnostics\" when set."
  }
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}
