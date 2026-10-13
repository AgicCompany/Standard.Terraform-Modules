mock_provider "azurerm" {}

variables {
  resource_group_name     = "rg-test-weu-001"
  location                = "westeurope"
  name                    = "sttestweu001"
  enable_private_endpoint = false
}

run "defaults_render_no_identity_and_no_cmk" {
  command = plan

  assert {
    condition     = length(azurerm_storage_account.this.identity) == 0
    error_message = "No identity block should render by default."
  }

  assert {
    condition     = length(azurerm_storage_account.this.customer_managed_key) == 0
    error_message = "No customer-managed key block should render by default."
  }
}

run "cmk_with_key_vault_key" {
  command = plan

  variables {
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"]
    }
    customer_managed_key = {
      key_vault_key_id          = "https://kv-test-weu-001.vault.azure.net/keys/key-st-cmk/0123456789abcdef0123456789abcdef"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    }
  }

  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].key_vault_key_id == "https://kv-test-weu-001.vault.azure.net/keys/key-st-cmk/0123456789abcdef0123456789abcdef"
    error_message = "The versioned Key Vault key ID should render unchanged."
  }

  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].user_assigned_identity_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    error_message = "The CMK block should use the attached user-assigned identity."
  }

  assert {
    condition     = azurerm_storage_account.this.identity[0].type == "UserAssigned"
    error_message = "The user-assigned identity type should render unchanged."
  }
}

run "cmk_with_versionless_key_vault_key" {
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
  }

  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].key_vault_key_id == "https://kv-test-weu-001.vault.azure.net/keys/key-st-cmk"
    error_message = "The versionless Key Vault key ID should render unchanged for automatic rotation."
  }
}

run "cmk_with_managed_hsm_key" {
  command = plan

  variables {
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"]
    }
    customer_managed_key = {
      managed_hsm_key_id        = "https://hsm-test-weu-001.managedhsm.azure.net/keys/key-st-cmk"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    }
  }

  # The provider accepts HSM keys through key_vault_key_id. Its own
  # managed_hsm_key_id attribute is deprecated and removed in azurerm 5.0.
  assert {
    condition     = azurerm_storage_account.this.customer_managed_key[0].key_vault_key_id == "https://hsm-test-weu-001.managedhsm.azure.net/keys/key-st-cmk"
    error_message = "The Managed HSM key ID should render through key_vault_key_id."
  }
}

run "cmk_with_system_and_user_assigned_identity" {
  command = plan

  variables {
    identity = {
      type         = "SystemAssigned, UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"]
    }
    customer_managed_key = {
      key_vault_key_id          = "https://kv-test-weu-001.vault.azure.net/keys/key-st-cmk/0123456789abcdef0123456789abcdef"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    }
  }

  assert {
    condition     = length(azurerm_storage_account.this.customer_managed_key) == 1
    error_message = "The CMK block should render when both identity types are configured."
  }

  assert {
    condition     = azurerm_storage_account.this.identity[0].type == "SystemAssigned, UserAssigned"
    error_message = "The combined identity type should render unchanged."
  }
}

run "rejects_both_key_ids" {
  command = plan

  variables {
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"]
    }
    customer_managed_key = {
      key_vault_key_id          = "https://kv-test-weu-001.vault.azure.net/keys/key-st-cmk/0123456789abcdef0123456789abcdef"
      managed_hsm_key_id        = "https://hsm-test-weu-001.managedhsm.azure.net/keys/key-st-cmk"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    }
  }

  expect_failures = [var.customer_managed_key]
}

run "rejects_neither_key_id" {
  command = plan

  variables {
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"]
    }
    customer_managed_key = {
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    }
  }

  expect_failures = [var.customer_managed_key]
}

run "rejects_cmk_without_identity" {
  command = plan

  variables {
    customer_managed_key = {
      key_vault_key_id          = "https://kv-test-weu-001.vault.azure.net/keys/key-st-cmk/0123456789abcdef0123456789abcdef"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    }
  }

  expect_failures = [azurerm_storage_account.this]
}

run "rejects_cmk_identity_not_attached" {
  command = plan

  variables {
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-other"]
    }
    customer_managed_key = {
      key_vault_key_id          = "https://kv-test-weu-001.vault.azure.net/keys/key-st-cmk/0123456789abcdef0123456789abcdef"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    }
  }

  expect_failures = [azurerm_storage_account.this]
}

run "rejects_cmk_with_system_assigned_only" {
  command = plan

  variables {
    identity = {
      type = "SystemAssigned"
    }
    customer_managed_key = {
      key_vault_key_id          = "https://kv-test-weu-001.vault.azure.net/keys/key-st-cmk/0123456789abcdef0123456789abcdef"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    }
  }

  expect_failures = [azurerm_storage_account.this]
}

run "rejects_cmk_on_unsupported_account_kind" {
  command = plan

  variables {
    account_kind = "BlobStorage"
    account_tier = "Standard"
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"]
    }
    customer_managed_key = {
      key_vault_key_id          = "https://kv-test-weu-001.vault.azure.net/keys/key-st-cmk/0123456789abcdef0123456789abcdef"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-weu-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-st-cmk"
    }
  }

  expect_failures = [azurerm_storage_account.this]
}

run "rejects_bad_identity_type" {
  command = plan

  variables {
    identity = {
      type = "SystemAssigned,UserAssigned"
    }
  }

  expect_failures = [var.identity]
}
