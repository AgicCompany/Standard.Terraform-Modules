resource "azurerm_monitor_diagnostic_setting" "this" {
  name                           = var.name
  target_resource_id             = var.target_resource_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type

  # When enabled_log_categories is null, send all logs via the "allLogs" category group
  dynamic "enabled_log" {
    for_each = var.enabled_log_categories == null ? ["allLogs"] : []

    content {
      category_group = enabled_log.value
    }
  }

  # When enabled_log_categories is specified, send only those categories
  dynamic "enabled_log" {
    for_each = var.enabled_log_categories != null ? var.enabled_log_categories : []

    content {
      category = enabled_log.value
    }
  }

  # When metric_categories is null, send all metrics via the "AllMetrics" category group
  dynamic "metric" {
    for_each = var.metric_categories == null ? ["AllMetrics"] : []

    content {
      category = metric.value
    }
  }

  # When metric_categories is specified, send only those categories
  dynamic "metric" {
    for_each = var.metric_categories != null ? var.metric_categories : []

    content {
      category = metric.value
    }
  }
}
