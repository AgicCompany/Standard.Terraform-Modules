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
  name     = "rg-caj-complete-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_user_assigned_identity" "job" {
  name                = "id-caj-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# In practice, the ACR is often in a separate shared/platform resource group.
data "azurerm_container_registry" "example" {
  name                = "acrexampledevweu001"
  resource_group_name = azurerm_resource_group.example.name
}

data "azurerm_key_vault" "example" {
  name                = "kv-example-dev-weu-001"
  resource_group_name = azurerm_resource_group.example.name
}

data "azurerm_key_vault_secret" "api_key" {
  name         = "api-key"
  key_vault_id = data.azurerm_key_vault.example.id
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-caj-complete-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-caj-complete-dev-weu-001"
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

resource "azurerm_container_app_environment" "example" {
  name                           = "cae-complete-dev-weu-001"
  location                       = azurerm_resource_group.example.location
  resource_group_name            = azurerm_resource_group.example.name
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

module "container_app_job" {
  source = "../../"

  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  name                         = "caj-complete-worker-dev"
  container_app_environment_id = azurerm_container_app_environment.example.id
  replica_timeout_in_seconds   = 1800
  replica_retry_limit          = 2
  workload_profile_name        = "dedicated-d4"

  container = {
    image  = "${data.azurerm_container_registry.example.login_server}/worker:latest"
    cpu    = 2.0
    memory = "4Gi"
    env = {
      "APP_ENV" = { value = "production" }
      "API_KEY" = { secret_name = "api-key" }
    }
    command = ["/bin/sh", "-c"]
    args    = ["echo Starting worker && ./worker"]
  }

  init_containers = [
    {
      name    = "db-migration"
      image   = "${data.azurerm_container_registry.example.login_server}/worker:latest"
      cpu     = 0.5
      memory  = "1Gi"
      command = ["/bin/sh", "-c", "echo Running migrations"]
    }
  ]

  user_assigned_identity_ids = [azurerm_user_assigned_identity.job.id]

  registries = [
    {
      server   = data.azurerm_container_registry.example.login_server
      identity = azurerm_user_assigned_identity.job.id
    }
  ]

  # Key Vault-referenced secret. The managed identity must have Key Vault Secrets User role.
  secrets = {
    "api-key" = {
      key_vault_secret_id = data.azurerm_key_vault_secret.api_key.id
      identity            = azurerm_user_assigned_identity.job.id
    }
  }

  event_trigger_config = {
    parallelism              = 2
    replica_completion_count = 1
    scale = {
      min_executions              = 0
      max_executions              = 10
      polling_interval_in_seconds = 60
      rules = [
        {
          name             = "queue-scale"
          custom_rule_type = "azure-servicebus"
          metadata = {
            namespace    = "sb-example-dev-weu-001"
            queueName    = "work-queue"
            messageCount = "5"
          }
          authentication = [
            {
              secret_name       = "api-key"
              trigger_parameter = "connection"
            }
          ]
        }
      ]
    }
  }

  enable_secret_ignore_changes = true

  tags = {
    project     = "complete-example"
    environment = "dev"
    owner       = "infrastructure-team"
    managed_by  = "terraform"
  }
}

output "container_app_job_id" {
  value = module.container_app_job.id
}

output "container_app_job_name" {
  value = module.container_app_job.name
}

output "container_app_job_outbound_ips" {
  value = module.container_app_job.outbound_ip_addresses
}

output "container_app_job_principal_id" {
  value = module.container_app_job.principal_id
}
