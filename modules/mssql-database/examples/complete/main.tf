provider "azurerm" {
  features {}
}

resource "azurerm_mssql_server" "example" {
  name                = "sql-payments-prod-weu-001"
  resource_group_name = "rg-data-prod-weu-001"
  location            = "westeurope"
  version             = "12.0"
  minimum_tls_version = "1.2"

  azuread_administrator {
    login_username              = "sqladmin@example.com"
    object_id                   = "00000000-0000-0000-0000-000000000000"
    azuread_authentication_only = true
  }

  tags = {
    environment = "prod"
    project     = "payments"
    cost_center = "finance"
  }
}

module "database" {
  source = "../../"

  name      = "payments-api"
  server_id = azurerm_mssql_server.example.id
  sku_name  = "P1"

  max_size_gb  = 50
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"

  short_term_retention_days   = 35
  enable_zone_redundancy      = true
  enable_geo_redundant_backup = true
  enable_read_scale           = true

  tags = {
    environment = "prod"
    project     = "payments"
    cost_center = "finance"
  }
}
