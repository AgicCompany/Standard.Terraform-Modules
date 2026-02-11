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
  name     = "rg-aks-nodepool-prod-weu-001"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-nodepool-prod-weu-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "system" {
  name                 = "snet-aks-system-prod-weu-001"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.0.0/22"]
}

resource "azurerm_subnet" "user" {
  name                 = "snet-aks-user-prod-weu-001"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.4.0/22"]
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aks-nodepool-prod-weu-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

module "aks" {
  source = "../../../aks"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "aks-nodepool-prod-weu-001"

  default_node_pool = {
    vnet_subnet_id = azurerm_subnet.system.id
  }

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    environment = "prod"
    project     = "nodepool-example"
  }
}

module "node_pools" {
  source = "../../"

  kubernetes_cluster_id = module.aks.id

  node_pools = {
    worker = {
      vm_size        = "Standard_D4s_v3"
      min_count      = 2
      max_count      = 10
      vnet_subnet_id = azurerm_subnet.user.id
      node_labels = {
        "workload" = "general"
      }
      upgrade_settings = {
        max_surge                     = "33%"
        drain_timeout_in_minutes      = 30
        node_soak_duration_in_minutes = 5
      }
      tags = {
        pool = "worker"
      }
    }

    gpu = {
      vm_size        = "Standard_NC6s_v3"
      min_count      = 0
      max_count      = 4
      vnet_subnet_id = azurerm_subnet.user.id
      node_labels = {
        "accelerator" = "nvidia"
      }
      node_taints = ["nvidia.com/gpu=true:NoSchedule"]
      tags = {
        pool = "gpu"
      }
    }

    spot = {
      vm_size         = "Standard_D4s_v3"
      min_count       = 0
      max_count       = 20
      priority        = "Spot"
      eviction_policy = "Delete"
      spot_max_price  = -1
      vnet_subnet_id  = azurerm_subnet.user.id
      node_labels = {
        "kubernetes.azure.com/scalesetpriority" = "spot"
      }
      node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
      tags = {
        pool = "spot"
      }
    }
  }
}

output "node_pool_ids" {
  value = module.node_pools.node_pool_ids
}

output "node_pool_names" {
  value = module.node_pools.node_pool_names
}
