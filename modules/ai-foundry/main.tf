resource "azurerm_ai_foundry" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  storage_account_id = var.storage_account_id
  key_vault_id       = var.key_vault_id

  application_insights_id = var.application_insights_id
  container_registry_id   = var.container_registry_id

  description   = var.description
  friendly_name = var.friendly_name

  high_business_impact_enabled = var.high_business_impact_enabled
  public_network_access        = var.enable_public_network_access ? "Enabled" : "Disabled"

  primary_user_assigned_identity = var.primary_user_assigned_identity

  identity {
    type         = var.identity_type
    identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : null
  }

  dynamic "managed_network" {
    for_each = var.managed_network_isolation_mode == null ? [] : [var.managed_network_isolation_mode]

    content {
      isolation_mode = managed_network.value
    }
  }

  dynamic "encryption" {
    for_each = var.encryption == null ? [] : [var.encryption]

    content {
      key_id                    = encryption.value.key_id
      key_vault_id              = encryption.value.key_vault_id
      user_assigned_identity_id = encryption.value.user_assigned_identity_id
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) || length(var.identity_ids) > 0
      error_message = "identity_ids must be non-empty when identity_type includes UserAssigned."
    }
  }
}

resource "azurerm_ai_foundry_project" "this" {
  name               = var.project_name
  location           = var.location
  ai_services_hub_id = azurerm_ai_foundry.this.id

  description                  = var.project_description
  friendly_name                = var.project_friendly_name
  high_business_impact_enabled = var.high_business_impact_enabled

  identity {
    type         = var.identity_type
    identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : null
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = coalesce(var.private_endpoint_name, "pep-${var.name}")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_ai_foundry.this.id
    subresource_names              = local.pe_subresource_names
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = var.tags
}


resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_ai_foundry.this.id

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
