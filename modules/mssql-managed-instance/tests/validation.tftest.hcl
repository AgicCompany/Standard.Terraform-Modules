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
