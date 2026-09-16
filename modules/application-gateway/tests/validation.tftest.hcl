# Regression tests for validation conditions that must not crash on
# Terraform 1.10 (no short-circuit evaluation of || in validations).
# Fully offline: the azurerm provider is mocked, nothing is applied.
mock_provider "azurerm" {}

variables {
  resource_group_name = "rg-test-weu-001"
  location            = "westeurope"
  name                = "agw-test-weu-001"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-agw"

  backend_address_pools = {
    pool1 = {
      fqdns = ["example.internal"]
    }
  }

  backend_http_settings = {
    setting1 = {
      port     = 80
      protocol = "Http"
    }
  }

  http_listeners = {
    listener1 = {
      frontend_port_name = "http"
      protocol           = "Http"
    }
  }

  request_routing_rules = {
    rule1 = {
      priority                   = 100
      http_listener_name         = "listener1"
      backend_address_pool_name  = "pool1"
      backend_http_settings_name = "setting1"
    }
  }
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
