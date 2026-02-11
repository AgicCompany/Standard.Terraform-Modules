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
  name     = "rg-aks-nodepool-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aks-nodepool-dev-weu-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "aks" {
  source = "../../../aks"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "aks-nodepool-dev-weu-001"

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    environment = "dev"
    project     = "nodepool-example"
  }
}

module "node_pools" {
  source = "../../"

  kubernetes_cluster_id = module.aks.id

  node_pools = {
    worker = {
      vm_size   = "Standard_D2s_v3"
      min_count = 1
      max_count = 5
    }
  }
}

output "node_pool_ids" {
  value = module.node_pools.node_pool_ids
}

output "node_pool_names" {
  value = module.node_pools.node_pool_names
}
