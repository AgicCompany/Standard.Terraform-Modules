resource "azurerm_mssql_managed_instance" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id          = var.subnet_id
  sku_name           = var.sku_name
  vcores             = var.vcores
  storage_size_in_gb = var.storage_size_in_gb
  license_type       = var.license_type

  administrator_login          = var.enable_aad_only_auth ? null : var.administrator_login
  administrator_login_password = var.enable_aad_only_auth ? null : var.administrator_login_password

  collation                      = var.collation
  timezone_id                    = var.timezone_id
  database_format                = var.database_format
  maintenance_configuration_name = var.maintenance_configuration_name
  storage_account_type           = var.storage_account_type
  hybrid_secondary_usage         = var.hybrid_secondary_usage
  proxy_override                 = var.proxy_override
  dns_zone_partner_id            = var.dns_zone_partner_id

  minimum_tls_version          = var.min_tls_version
  public_data_endpoint_enabled = var.enable_public_data_endpoint
  zone_redundant_enabled       = var.enable_zone_redundancy
  general_purpose_v2_enabled   = var.enable_general_purpose_v2

  # The instance-level service principal is what Entra authentication uses;
  # it is only available when a system-assigned identity exists.
  service_principal_type = strcontains(var.identity.type, "SystemAssigned") ? "SystemAssigned" : null

  azure_active_directory_administrator {
    login_username                      = var.azuread_administrator.login_username
    object_id                           = var.azuread_administrator.object_id
    principal_type                      = var.azuread_administrator.principal_type
    tenant_id                           = var.azuread_administrator.tenant_id
    azuread_authentication_only_enabled = var.enable_aad_only_auth
  }

  identity {
    type         = var.identity.type
    identity_ids = length(var.identity.identity_ids) > 0 ? var.identity.identity_ids : null
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  lifecycle {
    precondition {
      condition     = var.enable_aad_only_auth || (var.administrator_login != null && var.administrator_login_password != null)
      error_message = "administrator_login and administrator_login_password are required when enable_aad_only_auth is false."
    }

    precondition {
      condition     = strcontains(var.identity.type, "UserAssigned") == (length(var.identity.identity_ids) > 0)
      error_message = "identity.identity_ids must be non-empty when identity.type includes UserAssigned, and empty otherwise."
    }

    precondition {
      condition     = !var.enable_zone_redundancy || contains(["ZRS", "GZRS"], var.storage_account_type)
      error_message = "enable_zone_redundancy requires storage_account_type to be \"ZRS\" or \"GZRS\" (zone-redundant backup storage)."
    }
  }

  tags = var.tags
}

# Always present: TDE cannot be removed once enabled, and keeping the resource
# makes switching between service-managed and customer-managed keys an
# in-place update instead of a resource add/remove.
resource "azurerm_mssql_managed_instance_transparent_data_encryption" "this" {
  managed_instance_id   = azurerm_mssql_managed_instance.this.id
  key_vault_key_id      = var.customer_managed_key == null ? null : var.customer_managed_key.key_vault_key_id
  auto_rotation_enabled = var.customer_managed_key == null ? null : var.customer_managed_key.auto_rotation_enabled
}

resource "azurerm_mssql_managed_instance_security_alert_policy" "this" {
  count = var.enable_security_alert_policy ? 1 : 0

  resource_group_name   = var.resource_group_name
  managed_instance_name = azurerm_mssql_managed_instance.this.name

  enabled                      = true
  email_addresses              = var.security_alert_policy.email_addresses
  email_account_admins_enabled = var.security_alert_policy.email_account_admins_enabled
  disabled_alerts              = var.security_alert_policy.disabled_alerts
  retention_days               = var.security_alert_policy.retention_days
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.diagnostic_settings == null ? 0 : 1

  name               = coalesce(var.diagnostic_settings.name, "diag-${var.name}")
  target_resource_id = azurerm_mssql_managed_instance.this.id

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
