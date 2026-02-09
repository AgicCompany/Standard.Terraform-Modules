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

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-prod-weu-001"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-prod-weu-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "nodes" {
  name                 = "snet-aks-nodes-prod-weu-001"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.0.0/22"]
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-aks-prod-weu-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

module "aks" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "aks-payments-prod-weu-001"
  dns_prefix          = "aks-payments-prod"

  sku_tier                 = "Standard"
  node_resource_group_name = "rg-aks-payments-prod-weu-001-nodes"
  admin_group_object_ids   = [data.azurerm_client_config.current.object_id]

  default_node_pool = {
    vm_size         = "Standard_D4s_v3"
    vnet_subnet_id  = azurerm_subnet.nodes.id
    node_count      = 3
    min_count       = 3
    max_count       = 10
    os_disk_size_gb = 128
    os_sku          = "AzureLinux"
    zones           = ["1", "2", "3"]
    max_pods        = 50
    upgrade_settings = {
      max_surge                     = "33%"
      drain_timeout_in_minutes      = 30
      node_soak_duration_in_minutes = 5
    }
  }

  network_profile = {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    pod_cidr            = "10.244.0.0/16"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
    outbound_type       = "loadBalancer"
  }

  authorized_ip_ranges      = ["203.0.113.0/24"]
  automatic_upgrade_channel = "patch"

  # Feature flags
  enable_auto_scaling       = true
  enable_container_insights = true

  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    environment = "prod"
    project     = "payments"
    cost_center = "finance"
  }
}

output "cluster_id" {
  value = module.aks.id
}

output "cluster_name" {
  value = module.aks.name
}

output "private_fqdn" {
  value = module.aks.private_fqdn
}
