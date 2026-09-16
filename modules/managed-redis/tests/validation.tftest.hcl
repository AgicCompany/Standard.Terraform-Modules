# Regression tests for validation conditions that must not crash on
# Terraform 1.10 (no short-circuit evaluation of || in validations).
# Fully offline: the azurerm provider is mocked, nothing is applied.
mock_provider "azurerm" {}

variables {
  resource_group_name     = "rg-test-weu-001"
  location                = "westeurope"
  name                    = "redis-test-weu-001"
  sku_name                = "Balanced_B10"
  enable_private_endpoint = false
}

run "diagnostics_without_destination_type_do_not_crash" {
  command = plan
  variables {
    diagnostic_settings = {
      log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law-x"
    }
  }
  # No assert needed: the run passing means the validation evaluated
  # without error. (Formerly crashed on Terraform 1.10.)
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

run "defaults_with_null_identity_do_not_crash" {
  command = plan
}

run "rejects_cmk_without_user_assigned_identity" {
  command = plan
  variables {
    customer_managed_key = {
      key_vault_key_id = "https://kv-x.vault.azure.net/keys/k/0123456789abcdef0123456789abcdef"
      identity_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-x"
    }
  }
  expect_failures = [azurerm_managed_redis.this]
}
