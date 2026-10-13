terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-st-cmk-example-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-st-cmk-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault" "example" {
  name                       = "kv-stcmkexample-dev-001"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  rbac_authorization_enabled = true
}

resource "azurerm_role_assignment" "deployer_crypto_officer" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "cmk" {
  name         = "key-st-cmk"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA-HSM"
  key_size     = 3072
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_role_assignment.deployer_crypto_officer]
}

# Granting access to the key is the consumer's job; the module never creates this role assignment.
resource "azurerm_role_assignment" "storage_cmk" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}

module "storage_cmk" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "stcmkexampledevweu001"

  # Keep this example focused on encryption rather than networking.
  enable_private_endpoint = false

  identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }

  customer_managed_key = {
    key_vault_key_id          = azurerm_key_vault_key.cmk.versionless_id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }

  # queue_encryption_key_type and table_encryption_key_type are deliberately not set:
  # on a StorageV2 account with a customer-managed key the module defaults both to
  # "Account", so the key covers queue and table data too. Azure covers only blob and
  # file data on its own. Pass "Service" explicitly to opt out.

  tags = {
    project     = "example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }

  depends_on = [azurerm_role_assignment.storage_cmk]
}

# Managed HSM variant - the identity, the role assignment and every other input
# stay as they are; only the key source changes:
#
#   customer_managed_key = {
#     managed_hsm_key_id        = azurerm_key_vault_managed_hardware_security_module_key.cmk.versionless_id
#     user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
#   }
#
# Grant the identity "Managed HSM Crypto Service Encryption User" on the HSM key
# scope instead of the Key Vault role.

output "storage_account_id" {
  value = module.storage_cmk.id
}

output "identity" {
  value = module.storage_cmk.identity
}

output "key_vault_key_versionless_id" {
  value = azurerm_key_vault_key.cmk.versionless_id
}
