resource "azurerm_communication_service" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  data_location       = var.data_location

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !var.enable_custom_domain || var.domain_name != null
      error_message = "domain_name is required when enable_custom_domain = true."
    }
  }
}

resource "azurerm_email_communication_service" "this" {
  name                = local.effective_email_service_name
  resource_group_name = var.resource_group_name
  data_location       = var.data_location

  tags = var.tags
}

resource "azurerm_email_communication_service_domain" "this" {
  name              = local.effective_domain_name
  email_service_id  = azurerm_email_communication_service.this.id
  domain_management = local.domain_management

  user_engagement_tracking_enabled = var.user_engagement_tracking_enabled

  tags = var.tags
}

resource "azurerm_email_communication_service_domain_sender_username" "this" {
  for_each = var.sender_usernames

  name                    = each.value.username
  email_service_domain_id = azurerm_email_communication_service_domain.this.id
  display_name            = each.value.display_name
}

resource "azurerm_communication_service_email_domain_association" "this" {
  communication_service_id = azurerm_communication_service.this.id
  email_service_domain_id  = azurerm_email_communication_service_domain.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_communication_service.this.id

  log_analytics_workspace_id     = var.diagnostic_settings.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_settings.storage_account_id
  eventhub_authorization_rule_id = var.diagnostic_settings.eventhub_authorization_rule_id
  eventhub_name                  = var.diagnostic_settings.eventhub_name
  log_analytics_destination_type = var.diagnostic_settings.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = coalesce(
      var.diagnostic_settings.enabled_log_categories,
      try(data.azurerm_monitor_diagnostic_categories.this[0].log_category_types, [])
    )
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = coalesce(
      var.diagnostic_settings.enabled_metrics,
      try(data.azurerm_monitor_diagnostic_categories.this[0].metrics, [])
    )
    content {
      category = enabled_metric.value
    }
  }
}
