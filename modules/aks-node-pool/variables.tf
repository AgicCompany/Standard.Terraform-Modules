# === Required ===
variable "kubernetes_cluster_id" {
  type        = string
  description = "Resource ID of the AKS cluster to attach node pools to"
}

# === Node Pools ===
variable "node_pools" {
  type = map(object({
    vm_size                     = optional(string, "Standard_D2s_v3")
    node_count                  = optional(number, 3)
    auto_scaling_enabled        = optional(bool, true)
    min_count                   = optional(number, 1)
    max_count                   = optional(number, 5)
    mode                        = optional(string, "User")
    os_type                     = optional(string, "Linux")
    os_sku                      = optional(string, "AzureLinux")
    os_disk_size_gb             = optional(number, 128)
    os_disk_type                = optional(string, "Managed")
    vnet_subnet_id              = optional(string)
    zones                       = optional(list(string), ["1", "2", "3"])
    max_pods                    = optional(number, 30)
    node_labels                 = optional(map(string), {})
    node_taints                 = optional(list(string), [])
    priority                    = optional(string, "Regular")
    eviction_policy             = optional(string)
    spot_max_price              = optional(number)
    scale_down_mode             = optional(string, "Delete")
    temporary_name_for_rotation = optional(string)
    orchestrator_version        = optional(string)
    ultra_ssd_enabled           = optional(bool, false)
    host_encryption_enabled     = optional(bool, false)
    fips_enabled                = optional(bool, false)
    upgrade_settings = optional(object({
      max_surge                     = optional(string, "33%")
      drain_timeout_in_minutes      = optional(number, 30)
      node_soak_duration_in_minutes = optional(number, 0)
    }), {})
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of node pool configurations. Each key becomes the node pool name."

  validation {
    condition     = alltrue([for k, v in var.node_pools : contains(["User", "System"], v.mode)])
    error_message = "mode must be User or System."
  }

  validation {
    condition     = alltrue([for k, v in var.node_pools : contains(["Regular", "Spot"], v.priority)])
    error_message = "priority must be Regular or Spot."
  }

  validation {
    condition     = alltrue([for k, v in var.node_pools : contains(["Linux", "Windows"], v.os_type)])
    error_message = "os_type must be Linux or Windows."
  }

  validation {
    condition     = alltrue([for k, v in var.node_pools : contains(["Delete", "Deallocate"], v.scale_down_mode)])
    error_message = "scale_down_mode must be Delete or Deallocate."
  }
}
