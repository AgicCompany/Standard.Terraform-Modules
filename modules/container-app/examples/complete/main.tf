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
  name     = "rg-ca-complete-dev-weu-001"
  location = "westeurope"
}

# Log Analytics workspace (required by Container Apps Environment)
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-ca-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Virtual network for VNet integration
resource "azurerm_virtual_network" "example" {
  name                = "vnet-ca-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "cae" {
  name                 = "snet-cae"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/21"]

  delegation {
    name = "container-apps"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Container Apps Environment with workload profiles
resource "azurerm_container_app_environment" "example" {
  name                = "cae-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  log_analytics_workspace_id     = azurerm_log_analytics_workspace.example.id
  infrastructure_subnet_id       = azurerm_subnet.cae.id
  internal_load_balancer_enabled = true

  workload_profile {
    name                  = "dedicated-d4"
    workload_profile_type = "D4"
    minimum_count         = 1
    maximum_count         = 3
  }
}

# Container App with all features
module "container_app" {
  source = "../../"

  resource_group_name          = azurerm_resource_group.example.name
  name                         = "ca-api-complete-dev-weu-001"
  container_app_environment_id = azurerm_container_app_environment.example.id

  # Revision mode
  revision_mode = "Single"

  # Workload profile (use dedicated compute)
  workload_profile_name = "dedicated-d4"

  # Main container with probes
  container = {
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.5
    memory = "1Gi"

    env = {
      "APP_ENV" = {
        value = "production"
      }
      "DB_PASSWORD" = {
        secret_name = "db-password"
      }
    }

    liveness_probe = {
      transport               = "HTTP"
      port                    = 80
      path                    = "/health"
      initial_delay           = 5
      interval_seconds        = 10
      failure_count_threshold = 3
    }

    readiness_probe = {
      transport               = "HTTP"
      port                    = 80
      path                    = "/ready"
      interval_seconds        = 5
      failure_count_threshold = 3
    }

    startup_probe = {
      transport               = "HTTP"
      port                    = 80
      path                    = "/health"
      interval_seconds        = 3
      failure_count_threshold = 10
    }
  }

  # Init container
  init_containers = [
    {
      name    = "db-migration"
      image   = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu     = 0.25
      memory  = "0.5Gi"
      command = ["/bin/sh", "-c", "echo 'Running migrations...'"]
    }
  ]

  # Ingress (external for this example)
  enable_ingress          = true
  enable_external_ingress = true

  ingress = {
    target_port = 80
    transport   = "auto"
  }

  # Secrets
  secrets = {
    "db-password" = "supersecretpassword123"
  }

  # Scale rules
  scale = {
    min_replicas = 1
    max_replicas = 5
    rules = [
      {
        name = "http-scaling"
        http_scale_rule = {
          concurrent_requests = "50"
        }
      }
    ]
  }

  # System-assigned managed identity
  enable_system_assigned_identity = true

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "container_app_id" {
  value = module.container_app.id
}

output "container_app_fqdn" {
  value = module.container_app.latest_revision_fqdn
}

output "container_app_principal_id" {
  value = module.container_app.principal_id
}

output "container_app_outbound_ips" {
  value = module.container_app.outbound_ip_addresses
}
