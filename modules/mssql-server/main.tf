resource "azurerm_mssql_server" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  version             = var.version_number

  administrator_login          = var.enable_aad_only_auth ? null : var.administrator_login
  administrator_login_password = var.enable_aad_only_auth ? null : var.administrator_login_password

  minimum_tls_version                  = var.minimum_tls_version
  public_network_access_enabled        = var.enable_public_access
  outbound_network_restriction_enabled = var.enable_outbound_networking_restriction
  connection_policy                    = var.connection_policy

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username              = var.azuread_administrator.login_username
    object_id                   = var.azuread_administrator.object_id
    azuread_authentication_only = var.enable_aad_only_auth
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "this" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}
