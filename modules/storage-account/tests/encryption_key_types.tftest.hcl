# queue_encryption_key_type / table_encryption_key_type: the inputs that decide
# whether queue and table data sit under the account key (and therefore under a
# customer-managed key) or stay on Microsoft-managed service keys.
# Fully offline: the azurerm provider is mocked, nothing is applied.
mock_provider "azurerm" {}

variables {
  resource_group_name     = "rg-test-weu-001"
  location                = "westeurope"
  name                    = "sttestweu001"
  enable_private_endpoint = false
}

run "defaults_keep_service_scoped_keys" {
  command = plan

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Service"
    error_message = "queue_encryption_key_type must default to Service, matching the provider default."
  }

  assert {
    condition     = azurerm_storage_account.this.table_encryption_key_type == "Service"
    error_message = "table_encryption_key_type must default to Service, matching the provider default."
  }
}

run "account_scoped_keys_render" {
  command = plan

  variables {
    queue_encryption_key_type = "Account"
    table_encryption_key_type = "Account"
  }

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Account"
    error_message = "queue_encryption_key_type = Account must render unchanged."
  }

  assert {
    condition     = azurerm_storage_account.this.table_encryption_key_type == "Account"
    error_message = "table_encryption_key_type = Account must render unchanged."
  }
}

run "cmk_with_account_scoped_queue_and_table" {
  command = plan

  variables {
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"]
    }
    customer_managed_key = {
      key_vault_key_id          = "https://kv-test-weu-001.vault.azure.net/keys/key-st-cmk"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    }
    queue_encryption_key_type = "Account"
    table_encryption_key_type = "Account"
  }

  assert {
    condition     = length(azurerm_storage_account.this.customer_managed_key) == 1
    error_message = "The CMK block must still render alongside account-scoped queue and table keys."
  }

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Account"
    error_message = "Account-scoped queue encryption must survive a CMK configuration."
  }
}

run "rejects_bad_queue_encryption_key_type" {
  command = plan

  variables {
    queue_encryption_key_type = "account"
  }

  expect_failures = [var.queue_encryption_key_type]
}

run "rejects_bad_table_encryption_key_type" {
  command = plan

  variables {
    table_encryption_key_type = "Managed"
  }

  expect_failures = [var.table_encryption_key_type]
}

run "rejects_account_scoped_queue_key_on_gpv1" {
  command = plan

  variables {
    account_kind              = "Storage"
    queue_encryption_key_type = "Account"
  }

  expect_failures = [azurerm_storage_account.this]
}

run "rejects_account_scoped_table_key_on_gpv1" {
  command = plan

  variables {
    account_kind              = "Storage"
    table_encryption_key_type = "Account"
  }

  expect_failures = [azurerm_storage_account.this]
}

run "gpv1_with_service_scoped_keys_is_accepted" {
  command = plan

  variables {
    account_kind = "Storage"
  }

  assert {
    condition     = azurerm_storage_account.this.queue_encryption_key_type == "Service"
    error_message = "GPv1 accounts must still plan with the default service-scoped keys."
  }
}
