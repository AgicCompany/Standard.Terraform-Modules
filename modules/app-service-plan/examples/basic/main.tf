provider "azurerm" {
  features {}
}

module "app_plan" {
  source = "../../"

  resource_group_name = "rg-app-dev-weu-001"
  location            = "westeurope"
  name                = "asp-myapp-dev-weu-001"
  sku_name            = "B1"

  tags = {
    environment = "dev"
    project     = "myapp"
  }
}
