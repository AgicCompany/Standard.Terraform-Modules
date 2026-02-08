terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-identity-complete-dev-weu-001"
  location = "westeurope"
}

# User-assigned identity for an application workload
module "app_identity" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "id-app-dev-weu-001"

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

# Example: grant the identity Reader role on the resource group
resource "azurerm_role_assignment" "reader" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Reader"
  principal_id         = module.app_identity.principal_id
}

# Example: grant the identity Key Vault Secrets User role (for secret retrieval)
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.app_identity.principal_id
}

output "identity_id" {
  value = module.app_identity.id
}

output "principal_id" {
  value = module.app_identity.principal_id
}

output "client_id" {
  value = module.app_identity.client_id
}

output "tenant_id" {
  value = module.app_identity.tenant_id
}
