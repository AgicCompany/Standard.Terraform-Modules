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

run "redirect_rule_without_backend_does_not_crash" {
  command = plan
  variables {
    redirect_configurations = {
      redirect1 = {
        redirect_type        = "Permanent"
        target_listener_name = "listener1"
      }
    }
    request_routing_rules = {
      redirect_rule = {
        priority                    = 100
        http_listener_name          = "listener1"
        redirect_configuration_name = "redirect1"
      }
    }
  }
  # No assert needed: the run passing means the backend_address_pool_name /
  # backend_http_settings_name preconditions evaluated without crashing for
  # a redirect rule that sets neither. (Formerly crashed on Terraform 1.10.)
}

run "rejects_private_listener_without_private_frontend_ip" {
  command = plan
  variables {
    http_listeners = {
      listener1 = {
        frontend_port_name   = "http"
        protocol             = "Http"
        use_private_frontend = true
      }
    }
  }
  expect_failures = [azurerm_application_gateway.this]
}

run "rejects_key_vault_ssl_cert_without_user_assigned_identity" {
  command = plan
  variables {
    ssl_certificates = {
      cert1 = {
        key_vault_secret_id = "https://kv-test.vault.azure.net/secrets/cert1"
      }
    }
  }
  expect_failures = [azurerm_application_gateway.this]
}

run "rejects_waf_v2_without_policy" {
  command = plan
  variables {
    sku_name = "WAF_v2"
    sku_tier = "WAF_v2"
  }
  expect_failures = [azurerm_application_gateway.this]
}

run "rejects_dynamic_private_frontend_ip_allocation" {
  command = plan
  variables {
    private_frontend_ip_configuration = {
      private_ip_address            = "10.0.1.10"
      private_ip_address_allocation = "Dynamic"
    }
  }
  expect_failures = [var.private_frontend_ip_configuration]
}

run "accepts_waf_v2_with_managed_waf_policy_and_private_frontend" {
  command = plan
  variables {
    sku_name = "WAF_v2"
    sku_tier = "WAF_v2"
    waf_policy = {
      mode = "Prevention"
    }
    private_frontend_ip_configuration = {
      private_ip_address = "10.0.1.10"
    }
    http_listeners = {
      listener1 = {
        frontend_port_name   = "http"
        protocol             = "Http"
        use_private_frontend = true
      }
    }
  }
}

run "rejects_trusted_root_cert_with_both_data_and_key_vault_secret_id" {
  command = plan
  variables {
    trusted_root_certificates = {
      rootca = {
        data                = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA..."
        key_vault_secret_id = "https://kv-test.vault.azure.net/secrets/rootca"
      }
    }
  }
  expect_failures = [var.trusted_root_certificates]
}

run "rejects_trusted_root_cert_with_neither_data_nor_key_vault_secret_id" {
  command = plan
  variables {
    trusted_root_certificates = {
      rootca = {}
    }
  }
  expect_failures = [var.trusted_root_certificates]
}

run "rejects_trusted_root_cert_key_vault_secret_id_without_identity" {
  command = plan
  variables {
    trusted_root_certificates = {
      rootca = {
        key_vault_secret_id = "https://kv-test.vault.azure.net/secrets/rootca"
      }
    }
  }
  expect_failures = [azurerm_application_gateway.this]
}

run "rejects_backend_http_settings_referencing_unknown_trusted_root_cert" {
  command = plan
  variables {
    backend_http_settings = {
      setting1 = {
        port                           = 443
        protocol                       = "Https"
        trusted_root_certificate_names = ["nonexistent-ca"]
      }
    }
  }
  expect_failures = [azurerm_application_gateway.this]
}

run "accepts_valid_trusted_root_certificate_on_backend_http_settings" {
  command = plan
  variables {
    trusted_root_certificates = {
      internal-ca = {
        data = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA..."
      }
    }
    backend_http_settings = {
      setting1 = {
        port                           = 443
        protocol                       = "Https"
        trusted_root_certificate_names = ["internal-ca"]
      }
    }
  }
}
