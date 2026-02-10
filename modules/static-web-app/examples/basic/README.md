# Example: Basic Usage

Deploys a Static Web App with Free tier defaults.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated (`az login`)

## What This Creates

- Resource group `rg-stapp-example-dev-weu-001`
- Static Web App `stapp-example-dev-weu-001` with:
  - Free SKU
  - Preview environments enabled
  - Configuration file changes enabled

## Clean Up

```bash
terraform destroy
```
