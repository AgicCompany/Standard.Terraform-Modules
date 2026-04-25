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

# --- Resource Group ---

resource "azurerm_resource_group" "this" {
  name     = "rg-tftest-aks-weu-001"
  location = "westeurope"
}

# --- Module 1: Virtual Network ---

module "virtual_network" {
  source = "../../../modules/virtual-network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vnet-tftest-aks-weu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-pe = {
      address_prefixes                  = ["10.0.1.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# --- Module 2: Log Analytics Workspace ---

module "log_analytics" {
  source = "../../../modules/log-analytics-workspace"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "law-tftest-aks-weu-001"

  tags = { environment = "test", project = "tftest" }
}

# --- Module 3: Private DNS Zone (ACR) ---

module "private_dns_zone" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.azurecr.io"

  virtual_network_links = {
    vnet-aks = {
      virtual_network_id   = module.virtual_network.id
      registration_enabled = false
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# --- Module 4: Container Registry (with PE) ---

module "container_registry" {
  source = "../../../modules/container-registry"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "crtftestaksweu001"

  sku = "Premium"

  enable_private_endpoint = true
  subnet_id               = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_id     = module.private_dns_zone.id

  tags = { environment = "test", project = "tftest" }
}

# --- Module 5: AKS (with Container Insights) ---

module "aks" {
  source = "../../../modules/aks"

  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  name                       = "aks-tftest-aks-weu-001"
  log_analytics_workspace_id = module.log_analytics.id

  default_node_pool = {
    vm_size    = "Standard_B2s"
    node_count = 1
    zones      = []
  }

  enable_auto_scaling       = false
  enable_container_insights = true

  tags = { environment = "test", project = "tftest" }
}

# --- Outputs ---

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = module.virtual_network.id
}

output "acr_login_server" {
  value = module.container_registry.login_server
}

output "acr_private_ip" {
  value = module.container_registry.private_ip_address
}

output "aks_id" {
  value = module.aks.id
}

output "aks_name" {
  value = module.aks.name
}

output "aks_fqdn" {
  value = module.aks.fqdn
}

output "aks_node_resource_group" {
  value = module.aks.node_resource_group
}
