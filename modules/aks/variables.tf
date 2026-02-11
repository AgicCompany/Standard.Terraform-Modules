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
  description = "AKS cluster name (full CAF-compliant name, provided by consumer)"
}

# === Optional: Configuration ===
variable "dns_prefix" {
  type        = string
  default     = null
  description = "DNS prefix for the cluster. When null, defaults to the name variable."
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "Kubernetes version. null = latest stable version available in the region."
}

variable "sku_tier" {
  type        = string
  default     = "Free"
  description = "SKU tier: Free, Standard (includes Uptime SLA), or Premium."

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Free, Standard, or Premium."
  }
}

variable "default_node_pool" {
  type = object({
    vm_size                     = optional(string, "Standard_D2s_v3")
    vnet_subnet_id              = optional(string)
    node_count                  = optional(number, 3)
    min_count                   = optional(number, 1)
    max_count                   = optional(number, 5)
    os_disk_size_gb             = optional(number, 128)
    os_disk_type                = optional(string, "Managed")
    os_sku                      = optional(string, "AzureLinux")
    zones                       = optional(list(string), ["1", "2", "3"])
    max_pods                    = optional(number, 30)
    temporary_name_for_rotation = optional(string, "tmpnodepool")
    upgrade_settings = optional(object({
      max_surge                     = optional(string, "33%")
      drain_timeout_in_minutes      = optional(number, 30)
      node_soak_duration_in_minutes = optional(number, 0)
    }), {})
  })
  default     = {}
  description = "Default (system) node pool configuration."
}

variable "network_profile" {
  type = object({
    network_plugin      = optional(string, "azure")
    network_plugin_mode = optional(string, "overlay")
    network_policy      = optional(string, "azure")
    pod_cidr            = optional(string, "10.244.0.0/16")
    service_cidr        = optional(string, "10.0.0.0/16")
    dns_service_ip      = optional(string, "10.0.0.10")
    outbound_type       = optional(string, "loadBalancer")
  })
  default     = {}
  description = "Network configuration. Defaults to Azure CNI Overlay."
}

variable "authorized_ip_ranges" {
  type        = list(string)
  default     = []
  description = "Public IP CIDRs allowed to reach the API server. Empty = fully private."
}

variable "admin_group_object_ids" {
  type        = list(string)
  default     = []
  description = "Azure AD group object IDs for cluster admin access."
}

variable "rbac_mode" {
  type        = string
  default     = "azure"
  description = "Authorization mode: 'azure' (Azure RBAC) or 'kubernetes' (Kubernetes RBAC). Azure AD authentication is always enabled regardless of mode."

  validation {
    condition     = contains(["azure", "kubernetes"], var.rbac_mode)
    error_message = "rbac_mode must be 'azure' or 'kubernetes'."
  }
}

variable "key_vault_secrets_provider" {
  type = object({
    secret_rotation_enabled  = optional(bool, false)
    secret_rotation_interval = optional(string, "2m")
  })
  default     = null
  description = "Key Vault CSI driver configuration. When null, the add-on is disabled."
}

variable "node_resource_group_name" {
  type        = string
  default     = null
  description = "Custom name for the auto-created node resource group. When null, Azure generates MC_<rg>_<cluster>_<region>."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics workspace ID. Required when enable_container_insights = true."

  validation {
    condition     = var.log_analytics_workspace_id != null || !var.enable_container_insights
    error_message = "log_analytics_workspace_id is required when enable_container_insights is true."
  }
}

variable "automatic_upgrade_channel" {
  type        = string
  default     = "none"
  description = "Auto-upgrade channel: none, patch, stable, rapid, or node-image."

  validation {
    condition     = contains(["none", "patch", "stable", "rapid", "node-image"], var.automatic_upgrade_channel)
    error_message = "automatic_upgrade_channel must be none, patch, stable, rapid, or node-image."
  }
}

# === Optional: Feature Flags ===
variable "enable_auto_scaling" {
  type        = bool
  default     = true
  description = "Enable cluster autoscaler on the default node pool"
}

variable "enable_container_insights" {
  type        = bool
  default     = true
  description = "Enable Container Insights via Log Analytics"
}

variable "workload_identity_enabled" {
  type        = bool
  default     = false
  description = "Enable workload identity for pod-to-Azure-service authentication"
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
