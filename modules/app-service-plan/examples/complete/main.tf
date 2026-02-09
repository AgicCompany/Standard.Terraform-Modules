provider "azurerm" {
  features {}
}

module "app_plan" {
  source = "../../"

  resource_group_name = "rg-app-prod-weu-001"
  location            = "westeurope"
  name                = "asp-payments-prod-weu-001"
  sku_name            = "P1v3"

  worker_count            = 3
  enable_zone_redundancy  = true
  enable_per_site_scaling = true

  tags = {
    environment = "prod"
    project     = "payments"
    cost_center = "finance"
  }
}
