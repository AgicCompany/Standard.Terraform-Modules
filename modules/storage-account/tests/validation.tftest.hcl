# Regression tests for validation conditions that must not crash on
# Terraform 1.10 (no short-circuit evaluation of || in validations).
# Fully offline: the azurerm provider is mocked, nothing is applied.
mock_provider "azurerm" {}

variables {
  resource_group_name     = "rg-test-weu-001"
  location                = "westeurope"
  name                    = "sttestweu001"
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

run "rejects_nfs_file_share_with_https_traffic_only" {
  command = plan
  variables {
    account_kind              = "FileStorage"
    account_tier              = "Premium"
    enable_https_traffic_only = true
    file_shares = {
      nfsshare = {
        quota            = 100
        enabled_protocol = "NFS"
      }
    }
  }
  expect_failures = [azurerm_storage_account.this]
}

run "rejects_nfs_file_share_quota_below_100" {
  command = plan
  variables {
    account_kind              = "FileStorage"
    account_tier              = "Premium"
    enable_https_traffic_only = false
    file_shares = {
      nfsshare = {
        quota            = 50
        enabled_protocol = "NFS"
      }
    }
  }
  expect_failures = [var.file_shares]
}

run "accepts_nfs_file_share_on_premium_filestorage" {
  command = plan
  variables {
    account_kind              = "FileStorage"
    account_tier              = "Premium"
    enable_https_traffic_only = false
    file_shares = {
      nfsshare = {
        quota            = 100
        enabled_protocol = "NFS"
      }
    }
  }
}
