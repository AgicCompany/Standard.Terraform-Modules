# Static tests for variable validations and resource preconditions.
# Runs fully offline: the azurerm provider is mocked, nothing is applied.
mock_provider "azurerm" {}

variables {
  resource_group_name = "rg-sqlmi-test-weu-001"
  location            = "westeurope"
  name                = "sqlmi-test-weu-001"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-net/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-sqlmi"
  sku_name            = "GP_Gen5"
  vcores              = 4
  storage_size_in_gb  = 32

  azuread_administrator = {
    login_username = "sqlmi-admins"
    object_id      = "11111111-1111-1111-1111-111111111111"
    principal_type = "Group"
  }
}

# --- variable validations ---------------------------------------------------

run "rejects_retired_gen4_sku" {
  command = plan
  variables {
    sku_name = "GP_Gen4"
  }
  expect_failures = [var.sku_name]
}

run "rejects_unsupported_vcores" {
  command = plan
  variables {
    vcores = 5
  }
  expect_failures = [var.vcores]
}

run "rejects_storage_not_multiple_of_32" {
  command = plan
  variables {
    storage_size_in_gb = 100
  }
  expect_failures = [var.storage_size_in_gb]
}

run "rejects_unknown_principal_type" {
  command = plan
  variables {
    azuread_administrator = {
      login_username = "x"
      object_id      = "11111111-1111-1111-1111-111111111111"
      principal_type = "ServicePrincipal"
    }
  }
  expect_failures = [var.azuread_administrator]
}

run "rejects_bad_license_type" {
  command = plan
  variables {
    license_type = "AHUB"
  }
  expect_failures = [var.license_type]
}

run "rejects_weak_password" {
  command = plan
  variables {
    enable_aad_only_auth         = false
    administrator_login          = "sqladmin"
    administrator_login_password = "weakpassword"
  }
  expect_failures = [var.administrator_login_password]
}

run "rejects_tls_below_1_2" {
  command = plan
  variables {
    min_tls_version = "1.0"
  }
  expect_failures = [var.min_tls_version]
}

run "rejects_bad_storage_account_type" {
  command = plan
  variables {
    storage_account_type = "RA-GRS"
  }
  expect_failures = [var.storage_account_type]
}

run "rejects_bad_proxy_override" {
  command = plan
  variables {
    proxy_override = "Direct"
  }
  expect_failures = [var.proxy_override]
}

run "rejects_bad_database_format" {
  command = plan
  variables {
    database_format = "SQLServer2019"
  }
  expect_failures = [var.database_format]
}

run "rejects_bad_hybrid_secondary_usage" {
  command = plan
  variables {
    hybrid_secondary_usage = "Standby"
  }
  expect_failures = [var.hybrid_secondary_usage]
}

run "rejects_bad_identity_type" {
  command = plan
  variables {
    identity = { type = "None" }
  }
  expect_failures = [var.identity]
}

run "rejects_unknown_disabled_alert" {
  command = plan
  variables {
    security_alert_policy = { disabled_alerts = ["Sql_Injection", "Coffee_Spill"] }
  }
  expect_failures = [var.security_alert_policy]
}

run "rejects_diagnostics_without_sink" {
  command = plan
  variables {
    diagnostic_settings = { name = "diag" }
  }
  expect_failures = [var.diagnostic_settings]
}

run "rejects_bad_log_analytics_destination_type" {
  command = plan
  variables {
    diagnostic_settings = {
      log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law-x"
      log_analytics_destination_type = "Foo"
    }
  }
  expect_failures = [var.diagnostic_settings]
}

# --- resource preconditions -------------------------------------------------

run "requires_sql_admin_when_not_aad_only" {
  command = plan
  variables {
    enable_aad_only_auth = false
  }
  expect_failures = [azurerm_mssql_managed_instance.this]
}

run "rejects_user_assigned_without_identity_ids" {
  command = plan
  variables {
    identity = { type = "UserAssigned" }
  }
  expect_failures = [azurerm_mssql_managed_instance.this]
}

run "rejects_identity_ids_without_user_assigned" {
  command = plan
  variables {
    identity = {
      type         = "SystemAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-x"]
    }
  }
  expect_failures = [azurerm_mssql_managed_instance.this]
}

# --- behaviour --------------------------------------------------------------

run "secure_defaults" {
  command = plan

  assert {
    condition     = azurerm_mssql_managed_instance.this.public_data_endpoint_enabled == false
    error_message = "public data endpoint must be disabled by default"
  }
  assert {
    condition     = azurerm_mssql_managed_instance.this.minimum_tls_version == "1.2"
    error_message = "minimum TLS must be 1.2"
  }
  assert {
    condition     = azurerm_mssql_managed_instance.this.azure_active_directory_administrator[0].azuread_authentication_only_enabled == true
    error_message = "Entra-only auth must be on by default"
  }
  assert {
    condition     = azurerm_mssql_managed_instance.this.administrator_login == null
    error_message = "SQL admin login must not be set under Entra-only auth"
  }
  assert {
    condition     = azurerm_mssql_managed_instance.this.identity[0].type == "SystemAssigned"
    error_message = "default identity must be SystemAssigned"
  }
  assert {
    condition     = azurerm_mssql_managed_instance.this.service_principal_type == "SystemAssigned"
    error_message = "service principal must be set when identity includes SystemAssigned"
  }
  assert {
    condition     = azurerm_mssql_managed_instance_transparent_data_encryption.this.key_vault_key_id == null
    error_message = "TDE must default to service-managed key"
  }
  assert {
    condition     = length(azurerm_mssql_managed_instance_security_alert_policy.this) == 1
    error_message = "security alert policy must be created by default"
  }
  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 0
    error_message = "diagnostic setting must not be created when diagnostic_settings is null"
  }
}

run "customer_managed_key_wires_tde" {
  command = plan
  variables {
    identity = {
      type         = "SystemAssigned, UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-sqlmi"]
    }
    customer_managed_key = {
      key_vault_key_id      = "https://kv-x.vault.azure.net/keys/sqlmi-tde/0123456789abcdef0123456789abcdef"
      auto_rotation_enabled = true
    }
  }

  assert {
    condition     = azurerm_mssql_managed_instance_transparent_data_encryption.this.key_vault_key_id == "https://kv-x.vault.azure.net/keys/sqlmi-tde/0123456789abcdef0123456789abcdef"
    error_message = "TDE must use the customer-managed key"
  }
  assert {
    condition     = azurerm_mssql_managed_instance_transparent_data_encryption.this.auto_rotation_enabled == true
    error_message = "auto rotation must be passed through"
  }
}

run "mixed_auth_passes_sql_admin" {
  command = plan
  variables {
    enable_aad_only_auth         = false
    administrator_login          = "sqladmin"
    administrator_login_password = "Str0ng!Passw0rd#2026"
  }

  assert {
    condition     = azurerm_mssql_managed_instance.this.administrator_login == "sqladmin"
    error_message = "SQL admin login must be forwarded when Entra-only auth is off"
  }
  assert {
    condition     = azurerm_mssql_managed_instance.this.azure_active_directory_administrator[0].azuread_authentication_only_enabled == false
    error_message = "Entra-only flag must be off"
  }
}

run "alert_policy_can_be_disabled" {
  command = plan
  variables {
    enable_security_alert_policy = false
  }

  assert {
    condition     = length(azurerm_mssql_managed_instance_security_alert_policy.this) == 0
    error_message = "security alert policy must not be created when disabled"
  }
}

run "diagnostics_created_with_sink" {
  command = plan
  variables {
    diagnostic_settings = {
      log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law-x"
      enabled_log_categories     = ["ResourceUsageStats"]
      enabled_metrics            = []
    }
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 1
    error_message = "diagnostic setting must be created"
  }
  assert {
    condition     = azurerm_monitor_diagnostic_setting.this[0].name == "diag-sqlmi-test-weu-001"
    error_message = "diagnostic setting name must default to diag-<name>"
  }
}
