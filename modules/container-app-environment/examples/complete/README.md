# Example: Complete Usage

Demonstrates all features of the container-app-environment module including workload profiles and zone redundancy.

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

- Resource group `rg-cae-complete-dev-weu-001`
- Log Analytics workspace `law-cae-complete-dev-weu-001`
- Virtual network with a `/21` subnet delegated to `Microsoft.App/environments`
- Container Apps Environment `cae-complete-dev-weu-001` with:
  - Internal load balancer enabled
  - Log Analytics workspace integration
  - VNet integration
  - Zone redundancy enabled
  - Dedicated workload profiles (D4 and E4)

## Clean Up

```bash
terraform destroy
```
