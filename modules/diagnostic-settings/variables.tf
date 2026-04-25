# === Required ===
variable "name" {
  type        = string
  description = "Diagnostic setting name"
}

variable "target_resource_id" {
  type        = string
  description = "Resource ID of the target resource to monitor"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace resource ID for log destination"
}

# === Optional: Configuration ===
variable "enabled_log_categories" {
  type        = list(string)
  default     = null
  description = "Log categories to enable. When null, uses the 'allLogs' category group which may not be supported by all resource types. Specify explicit categories for resources that don't support category groups."

  validation {
    condition     = var.enabled_log_categories == null || length(var.enabled_log_categories) > 0
    error_message = "enabled_log_categories must be null (all logs) or a non-empty list. An empty list would disable all logging."
  }
}

variable "metric_categories" {
  type        = list(string)
  default     = null
  description = "Metric categories to enable. When null, uses 'AllMetrics' which may not be supported by all resource types. Specify explicit categories if the target resource uses named metric categories."

  validation {
    condition     = var.metric_categories == null || length(var.metric_categories) > 0
    error_message = "metric_categories must be null (all metrics) or a non-empty list. An empty list would disable all metrics."
  }
}

variable "log_analytics_destination_type" {
  type        = string
  default     = null
  description = "Log Analytics destination type. Use \"Dedicated\" for resource-specific tables or \"AzureDiagnostics\" for legacy single table."
}
