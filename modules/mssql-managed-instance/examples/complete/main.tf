terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.68.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

variable "sql_admin_password" {
  type        = string
  sensitive   = true
  description = "SQL administrator password (min 12 chars, upper/lower/digit/symbol). Supplied via TF_VAR_sql_admin_password."
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-sqlmi-example-prod-weu-001"
  location = "westeurope"
}

# --- Network prerequisites (consumer-owned) ---------------------------------

resource "azurerm_virtual_network" "example" {
  name                = "vnet-sqlmi-example-prod-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "sqlmi" {
  name                 = "snet-sqlmi"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.20.0.0/26"]

  delegation {
    name = "managedinstancedelegation"

    service_delegation {
      name = "Microsoft.Sql/managedInstances"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "sqlmi" {
  name                = "nsg-sqlmi-example-prod-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_route_table" "sqlmi" {
  name                = "rt-sqlmi-example-prod-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet_network_security_group_association" "sqlmi" {
  subnet_id                 = azurerm_subnet.sqlmi.id
  network_security_group_id = azurerm_network_security_group.sqlmi.id
}

resource "azurerm_subnet_route_table_association" "sqlmi" {
  subnet_id      = azurerm_subnet.sqlmi.id
  route_table_id = azurerm_route_table.sqlmi.id
}

# --- Observability ----------------------------------------------------------

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-sqlmi-example-prod-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# --- Customer-managed TDE key -----------------------------------------------
# The user-assigned identity is granted crypto rights on the vault before the
# instance exists, so TDE can bind to the key on first apply.

resource "azurerm_user_assigned_identity" "sqlmi" {
  name                = "id-sqlmi-example-prod-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault" "example" {
  name                       = "kv-sqlmi-ex-prod-weu-001"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90
  rbac_authorization_enabled = true
}

resource "azurerm_role_assignment" "deployer_crypto_officer" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "sqlmi_crypto_user" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.sqlmi.principal_id
}

resource "azurerm_key_vault_key" "tde" {
  name         = "sqlmi-tde-protector"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_role_assignment.deployer_crypto_officer]
}

# --- Managed instance -------------------------------------------------------

module "sql_managed_instance" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "sqlmi-payments-prod-weu-001"

  subnet_id          = azurerm_subnet.sqlmi.id
  sku_name           = "BC_Gen5"
  vcores             = 8
  storage_size_in_gb = 256
  license_type       = "BasePrice"

  azuread_administrator = {
    login_username = "sqlmi-admins"
    object_id      = data.azurerm_client_config.current.object_id
    principal_type = "User"
  }

  # Mixed authentication: Entra administrator plus a SQL login
  enable_aad_only_auth         = false
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_admin_password

  identity = {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.sqlmi.id]
  }

  customer_managed_key = {
    key_vault_key_id      = azurerm_key_vault_key.tde.versionless_id
    auto_rotation_enabled = true
  }

  storage_account_type           = "ZRS"
  proxy_override                 = "Redirect"
  timezone_id                    = "W. Europe Standard Time"
  maintenance_configuration_name = "SQL_WestEurope_MI_1"
  enable_zone_redundancy         = true

  security_alert_policy = {
    email_addresses              = ["security@contoso.com"]
    email_account_admins_enabled = true
    retention_days               = 30
  }

  diagnostic_settings = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  }

  tags = {
    project     = "example"
    environment = "prod"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.sqlmi,
    azurerm_subnet_route_table_association.sqlmi,
    azurerm_role_assignment.sqlmi_crypto_user,
  ]
}

output "managed_instance_id" {
  value = module.sql_managed_instance.id
}

output "managed_instance_fqdn" {
  value = module.sql_managed_instance.fqdn
}

output "managed_instance_dns_zone" {
  value = module.sql_managed_instance.dns_zone
}

output "managed_instance_principal_id" {
  value = module.sql_managed_instance.principal_id
}
