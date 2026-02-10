# Example: Complete Usage

Deploys a Static Web App with Standard tier, app settings, and tags.

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

- Resource group `rg-stapp-complete-dev-weu-001`
- Static Web App `stapp-complete-dev-weu-001` with:
  - Standard SKU
  - App settings (API_URL, FEATURE_FLAG)
  - Preview environments enabled
  - Custom tags

## Clean Up

```bash
terraform destroy
```
