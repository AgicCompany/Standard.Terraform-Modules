provider "azurerm" {
  features {}
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aks-dev-weu-001"
  resource_group_name = "rg-aks-dev-weu-001"
  location            = "westeurope"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "aks" {
  source = "../../"

  resource_group_name = "rg-aks-dev-weu-001"
  location            = "westeurope"
  name                = "aks-payments-dev-weu-001"

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    environment = "dev"
    project     = "payments"
  }
}
