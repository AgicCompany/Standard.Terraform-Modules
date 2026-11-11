# Regression tests for validation conditions that must not crash on
# Terraform 1.10 (no short-circuit evaluation of || in validations).
# Fully offline: the azurerm provider is mocked, nothing is applied.
mock_provider "azurerm" {}

variables {
  resource_group_name = "rg-test-weu-001"
  location            = "westeurope"
  name                = "aks-test-weu-001"
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

run "null_maintenance_windows_do_not_crash" {
  command = plan
  variables {
    maintenance_window              = null
    maintenance_window_auto_upgrade = null
    maintenance_window_node_os      = null
  }
}

run "rejects_bad_auto_upgrade_frequency" {
  command = plan
  variables {
    maintenance_window_auto_upgrade = {
      frequency = "Hourly"
      interval  = 1
      duration  = 4
    }
  }
  expect_failures = [var.maintenance_window_auto_upgrade]
}

run "rejects_bad_node_os_start_time" {
  command = plan
  variables {
    maintenance_window_node_os = {
      frequency  = "Weekly"
      interval   = 1
      duration   = 4
      start_time = "2am"
    }
  }
  expect_failures = [var.maintenance_window_node_os]
}

run "rejects_cilium_policy_without_cilium_data_plane" {
  command = plan
  variables {
    network_profile = {
      network_policy     = "cilium"
      network_data_plane = "azure"
    }
  }
  expect_failures = [var.network_profile]
}

run "accepts_cilium_policy_with_cilium_data_plane_and_critical_addons" {
  command = plan
  variables {
    default_node_pool = {
      only_critical_addons_enabled = true
    }
    network_profile = {
      network_policy     = "cilium"
      network_data_plane = "cilium"
    }
    key_vault_secrets_provider = {
      secret_rotation_enabled = true
    }
  }
}
