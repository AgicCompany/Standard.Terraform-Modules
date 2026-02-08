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
  description = "List of log categories to enable. Null sends all logs via the allLogs category group."
}

variable "metric_categories" {
  type        = list(string)
  default     = null
  description = "List of metric categories to enable. Null sends all metrics via the AllMetrics category group."
}

variable "log_analytics_destination_type" {
  type        = string
  default     = null
  description = "Log Analytics destination type. Use \"Dedicated\" for resource-specific tables or \"AzureDiagnostics\" for legacy single table."
}
