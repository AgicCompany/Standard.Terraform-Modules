# access_tier is gated on account_kind: the provider only accepts it for
# BlobStorage, FileStorage and StorageV2.
#
# Scope note: the provider raises the real error in CustomizeDiff, which a mocked
# provider never runs, so these runs cannot reproduce the original failure. They
# pin the gate's visible behaviour instead: supported kinds send the configured
# tier, unsupported kinds send nothing and the attribute falls through to the mock
# default below. A config value always beats a mock default, so if the gate ever
# regresses to passing var.access_tier unconditionally, the last two runs fail.
mock_provider "azurerm" {
  mock_resource "azurerm_storage_account" {
    defaults = {
      access_tier = "UNSET_BY_MODULE"
    }
  }
}

variables {
  resource_group_name     = "rg-test-weu-001"
  location                = "westeurope"
  name                    = "sttestweu001"
  enable_private_endpoint = false
}

run "storage_v2_keeps_the_default_access_tier" {
  command = plan

  assert {
    condition     = azurerm_storage_account.this.access_tier == "Hot"
    error_message = "StorageV2 accounts must still send the access_tier default."
  }
}

run "file_storage_keeps_an_explicit_access_tier" {
  command = plan

  variables {
    account_kind = "FileStorage"
    account_tier = "Premium"
    access_tier  = "Cool"
  }

  assert {
    condition     = azurerm_storage_account.this.access_tier == "Cool"
    error_message = "FileStorage supports access_tier and must send the configured value."
  }
}

run "blob_storage_keeps_an_explicit_access_tier" {
  command = plan

  variables {
    account_kind = "BlobStorage"
    access_tier  = "Cold"
  }

  assert {
    condition     = azurerm_storage_account.this.access_tier == "Cold"
    error_message = "BlobStorage supports access_tier and must send the configured value."
  }
}

run "block_blob_storage_does_not_send_an_access_tier" {
  command = apply

  variables {
    account_kind = "BlockBlobStorage"
    account_tier = "Premium"
  }

  assert {
    condition     = azurerm_storage_account.this.access_tier == "UNSET_BY_MODULE"
    error_message = "BlockBlobStorage must not send an access_tier; the provider rejects it at plan time."
  }
}

run "gpv1_storage_does_not_send_an_access_tier" {
  command = apply

  variables {
    account_kind = "Storage"
  }

  assert {
    condition     = azurerm_storage_account.this.access_tier == "UNSET_BY_MODULE"
    error_message = "Storage (GPv1) must not send an access_tier; the provider rejects it at plan time."
  }
}
