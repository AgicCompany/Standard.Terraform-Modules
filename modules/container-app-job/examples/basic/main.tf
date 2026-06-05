terraform {
  required_version = ">= 1.10.0"

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
  name     = "rg-caj-example-dev-weu-001"
  location = "westeurope"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-caj-example-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "example" {
  name                       = "cae-example-dev-weu-001"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_user_assigned_identity" "runner" {
  name                = "id-caj-runner-dev-weu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# In practice, the ACR is often in a separate shared/platform resource group.
data "azurerm_container_registry" "example" {
  name                = "acrexampledevweu001"
  resource_group_name = azurerm_resource_group.example.name
}

module "container_app_job" {
  source = "../../"

  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  name                         = "caj-example-runner-dev"
  container_app_environment_id = azurerm_container_app_environment.example.id
  replica_timeout_in_seconds   = 3600

  container = {
    image  = "${data.azurerm_container_registry.example.login_server}/github-runner:latest"
    cpu    = 1.0
    memory = "2Gi"
    env = {
      "GITHUB_OWNER"  = { value = "my-org" }
      "GITHUB_REPO"   = { value = "my-repo" }
      "RUNNER_LABELS" = { value = "self-hosted,linux" }
      "GITHUB_PAT"    = { secret_name = "github-pat" }
    }
  }

  user_assigned_identity_ids = [azurerm_user_assigned_identity.runner.id]

  registries = [
    {
      server   = data.azurerm_container_registry.example.login_server
      identity = azurerm_user_assigned_identity.runner.id
    }
  ]

  secrets = {
    "github-pat" = { value = "ghp_placeholder_replace_with_real_token" }
  }

  event_trigger_config = {
    parallelism              = 1
    replica_completion_count = 1
    scale = {
      min_executions              = 0
      max_executions              = 5
      polling_interval_in_seconds = 30
      rules = [
        {
          name             = "github-runner-scale"
          custom_rule_type = "github-runner"
          metadata = {
            githubApiURL              = "https://api.github.com"
            owner                     = "my-org"
            runnerScope               = "repo"
            repos                     = "my-repo"
            labels                    = "self-hosted,linux"
            targetWorkflowQueueLength = "1"
          }
          authentication = [
            {
              secret_name       = "github-pat"
              trigger_parameter = "personalAccessToken"
            }
          ]
        }
      ]
    }
  }

  tags = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

output "container_app_job_id" {
  value = module.container_app_job.id
}

output "container_app_job_name" {
  value = module.container_app_job.name
}
