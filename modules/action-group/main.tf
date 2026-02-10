resource "azurerm_monitor_action_group" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  short_name          = var.short_name
  enabled             = var.enabled

  dynamic "email_receiver" {
    for_each = var.email_receivers

    content {
      name                    = email_receiver.key
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }

  dynamic "sms_receiver" {
    for_each = var.sms_receivers

    content {
      name         = sms_receiver.key
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.webhook_receivers

    content {
      name                    = webhook_receiver.key
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = webhook_receiver.value.use_common_alert_schema

      dynamic "aad_auth" {
        for_each = webhook_receiver.value.aad_auth != null ? [webhook_receiver.value.aad_auth] : []

        content {
          object_id = aad_auth.value.object_id
          tenant_id = aad_auth.value.tenant_id
        }
      }
    }
  }

  dynamic "azure_app_push_receiver" {
    for_each = var.azure_app_push_receivers

    content {
      name          = azure_app_push_receiver.key
      email_address = azure_app_push_receiver.value.email_address
    }
  }

  tags = var.tags
}
