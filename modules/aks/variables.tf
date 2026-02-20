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
    load_balancer_profile = optional(object({
      managed_outbound_ip_count = optional(number)
      outbound_ip_address_ids   = optional(list(string))
      outbound_ip_prefix_ids    = optional(list(string))
      outbound_ports_allocated  = optional(number, 0)
      idle_timeout_in_minutes   = optional(number, 30)
    }))
  })
  default     = {}
  description = "Network configuration. Defaults to Azure CNI Overlay. The load_balancer_profile sub-block configures outbound traffic. The outbound source fields (managed_outbound_ip_count, outbound_ip_address_ids, outbound_ip_prefix_ids) are mutually exclusive."
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

variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups      = optional(bool)
    empty_bulk_delete_max            = optional(number)
    expander                         = optional(string)
    max_graceful_termination_sec     = optional(number)
    max_node_provisioning_time       = optional(string)
    max_unready_nodes                = optional(number)
    max_unready_percentage           = optional(number)
    new_pod_scale_up_delay           = optional(string)
    scale_down_delay_after_add       = optional(string)
    scale_down_delay_after_delete    = optional(string)
    scale_down_delay_after_failure   = optional(string)
    scale_down_unneeded              = optional(string)
    scale_down_unready               = optional(string)
    scale_down_utilization_threshold = optional(string)
    scan_interval                    = optional(string)
    skip_nodes_with_local_storage    = optional(bool)
    skip_nodes_with_system_pods      = optional(bool)
  })
  default     = null
  description = "Cluster autoscaler profile. When null, Azure defaults apply."

  validation {
    condition     = var.auto_scaler_profile == null || try(var.auto_scaler_profile.expander == null || contains(["least-waste", "priority", "most-pods", "random"], var.auto_scaler_profile.expander), true)
    error_message = "auto_scaler_profile.expander must be least-waste, priority, most-pods, or random."
  }
}

variable "maintenance_window" {
  type = object({
    allowed = list(object({
      day   = string
      hours = list(number)
    }))
    not_allowed = optional(list(object({
      start = string
      end   = string
    })))
  })
  default = {
    allowed = [
      { day = "Saturday", hours = [0, 1, 2, 3, 4, 5] },
      { day = "Sunday", hours = [0, 1, 2, 3, 4, 5] }
    ]
  }
  description = "General maintenance window. Defaults to Saturday+Sunday 00:00-06:00 UTC. Set to null to let Azure schedule at its discretion."
}

variable "maintenance_window_auto_upgrade" {
  type = object({
    frequency    = string
    interval     = number
    duration     = number
    day_of_week  = optional(string)
    day_of_month = optional(number)
    week_index   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string, "+00:00")
    start_date   = optional(string)
    not_allowed = optional(list(object({
      start = string
      end   = string
    })))
  })
  default = {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "02:00"
  }
  description = "Auto-upgrade maintenance window. Defaults to Weekly Sunday 02:00 UTC, 4h duration. Set to null to disable."

  validation {
    condition     = var.maintenance_window_auto_upgrade == null || contains(["Daily", "Weekly", "AbsoluteMonthly", "RelativeMonthly"], var.maintenance_window_auto_upgrade.frequency)
    error_message = "frequency must be Daily, Weekly, AbsoluteMonthly, or RelativeMonthly."
  }

  validation {
    condition     = var.maintenance_window_auto_upgrade == null || (var.maintenance_window_auto_upgrade.duration >= 4 && var.maintenance_window_auto_upgrade.duration <= 24)
    error_message = "duration must be between 4 and 24 hours."
  }
}

variable "maintenance_window_node_os" {
  type = object({
    frequency    = string
    interval     = number
    duration     = number
    day_of_week  = optional(string)
    day_of_month = optional(number)
    week_index   = optional(string)
    start_time   = optional(string)
    utc_offset   = optional(string, "+00:00")
    start_date   = optional(string)
    not_allowed = optional(list(object({
      start = string
      end   = string
    })))
  })
  default = {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Saturday"
    start_time  = "02:00"
  }
  description = "Node OS upgrade maintenance window. Defaults to Weekly Saturday 02:00 UTC, 4h duration. Set to null to disable."

  validation {
    condition     = var.maintenance_window_node_os == null || contains(["Daily", "Weekly", "AbsoluteMonthly", "RelativeMonthly"], var.maintenance_window_node_os.frequency)
    error_message = "frequency must be Daily, Weekly, AbsoluteMonthly, or RelativeMonthly."
  }

  validation {
    condition     = var.maintenance_window_node_os == null || (var.maintenance_window_node_os.duration >= 4 && var.maintenance_window_node_os.duration <= 24)
    error_message = "duration must be between 4 and 24 hours."
  }
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Private DNS zone resource ID, \"System\", or \"None\". Only applies to private clusters (when authorized_ip_ranges is empty)."
}

# === Optional: Feature Flags ===
variable "enable_system_assigned_identity" {
  type        = bool
  default     = true
  description = "Enable system-assigned managed identity (default: true)"
}

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

# === Optional: Identity ===
variable "user_assigned_identity_ids" {
  type        = list(string)
  default     = []
  description = "List of user-assigned managed identity IDs"
}

# === Tags ===
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the resource"
}
