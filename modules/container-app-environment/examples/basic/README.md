# Example: Basic Usage

Demonstrates basic Container Apps Environment creation with VNet integration and internal load balancer.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated
- Existing resource group (or modify example to create one)

## What This Creates

- Resource group `rg-cae-example-dev-weu-001`
- Log Analytics workspace `law-cae-example-dev-weu-001`
- Virtual network with a `/23` subnet delegated to `Microsoft.App/environments`
- Container Apps Environment `cae-example-dev-weu-001` with:
  - Internal load balancer enabled (default)
  - Log Analytics workspace integration
  - VNet integration

## Clean Up

```bash
terraform destroy
```
