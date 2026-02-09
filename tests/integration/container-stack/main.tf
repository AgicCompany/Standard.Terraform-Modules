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
  name     = "rg-tftest-container-weu-001"
  location = "westeurope"
}

# --- Module 1: Virtual Network ---

module "virtual_network" {
  source = "../../../modules/virtual-network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "vnet-tftest-container-weu-001"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    snet-pe = {
      address_prefixes                  = ["10.0.1.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
    snet-cae = {
      address_prefixes = ["10.0.2.0/23"]
      delegation = {
        name = "cae"
        service_delegation = {
          name    = "Microsoft.App/environments"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
  }

  tags = { environment = "test", project = "tftest" }
}

# --- Module 2: Log Analytics Workspace ---

module "log_analytics" {
  source = "../../../modules/log-analytics-workspace"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name                = "law-tftest-container-weu-001"

  tags = { environment = "test", project = "tftest" }
}

# --- Module 3: Private DNS Zone (ACR) ---

module "private_dns_zone" {
  source = "../../../modules/private-dns-zone"

  resource_group_name = azurerm_resource_group.this.name
  name                = "privatelink.azurecr.io"

  virtual_network_links = {
    vnet-container = {
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
  name                = "crtftestcontainerweu001"

  sku = "Premium"

  enable_private_endpoint = true
  subnet_id               = module.virtual_network.subnet_ids["snet-pe"]
  private_dns_zone_id     = module.private_dns_zone.id

  tags = { environment = "test", project = "tftest" }
}

# --- Module 5: Container App Environment (internal LB) ---

module "container_app_environment" {
  source = "../../../modules/container-app-environment"

  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  name                       = "cae-tftest-container-weu-001"
  log_analytics_workspace_id = module.log_analytics.id

  enable_internal_load_balancer = true
  infrastructure_subnet_id     = module.virtual_network.subnet_ids["snet-cae"]

  tags = { environment = "test", project = "tftest" }
}

# --- Module 6: Container App ---

module "container_app" {
  source = "../../../modules/container-app"

  resource_group_name          = azurerm_resource_group.this.name
  name                         = "ca-tftest-container-weu-001"
  container_app_environment_id = module.container_app_environment.id

  container = {
    image  = "mcr.microsoft.com/k8se/quickstart:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }

  enable_ingress = true
  ingress = {
    target_port = 80
    transport   = "auto"
    traffic_weight = {
      latest = {
        latest_revision = true
        percentage      = 100
      }
    }
  }

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

output "cae_id" {
  value = module.container_app_environment.id
}

output "cae_default_domain" {
  value = module.container_app_environment.default_domain
}

output "cae_static_ip" {
  value = module.container_app_environment.static_ip_address
}

output "container_app_id" {
  value = module.container_app.id
}

output "container_app_fqdn" {
  value = module.container_app.latest_revision_fqdn
}
