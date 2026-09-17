# The minimum-viable environment (no infrastructure_subnet_id) must plan.
# azurerm rejects internal_load_balancer_enabled / zone_redundancy_enabled
# whenever they are set without infrastructure_subnet_id, even when false,
# so the module must pass null for both in that case.
# Fully offline: the azurerm provider is mocked, nothing is applied.
mock_provider "azurerm" {}

variables {
  resource_group_name        = "rg-test-weu-001"
  location                   = "westeurope"
  name                       = "cae-test-weu-001"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law-x"
}

run "plans_without_infrastructure_subnet" {
  command = plan
  # No assert needed: the run passing means the provider accepted the
  # resource without infrastructure_subnet_id.
}

run "plans_with_infrastructure_subnet_and_ilb" {
  command = plan
  variables {
    infrastructure_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/aca"
    enable_internal_load_balancer = true
    enable_zone_redundancy        = true
  }
  assert {
    condition     = azurerm_container_app_environment.this.internal_load_balancer_enabled == true
    error_message = "ILB flag must be forwarded when a subnet is given"
  }
}

run "rejects_ilb_without_subnet" {
  command = plan
  variables {
    enable_internal_load_balancer = true
  }
  expect_failures = [var.infrastructure_subnet_id]
}
