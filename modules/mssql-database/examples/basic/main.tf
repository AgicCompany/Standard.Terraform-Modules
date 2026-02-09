provider "azurerm" {
  features {}
}

resource "azurerm_mssql_server" "example" {
  name                = "sql-myapp-dev-weu-001"
  resource_group_name = "rg-data-dev-weu-001"
  location            = "westeurope"
  version             = "12.0"

  azuread_administrator {
    login_username              = "sqladmin@example.com"
    object_id                   = "00000000-0000-0000-0000-000000000000"
    azuread_authentication_only = true
  }

  tags = {
    environment = "dev"
    project     = "myapp"
  }
}

module "database" {
  source = "../../"

  name      = "myapp-api"
  server_id = azurerm_mssql_server.example.id

  tags = {
    environment = "dev"
    project     = "myapp"
  }
}
