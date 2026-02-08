# Example: Complete Usage

Demonstrates Log Analytics workspace creation with custom retention, daily quota, and internet access enabled.

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

- Resource group `rg-log-complete-dev-weu-001`
- Log Analytics workspace `log-complete-dev-weu-001` with:
  - PerGB2018 SKU
  - 90-day retention
  - 5 GB daily ingestion quota
  - Internet ingestion enabled
  - Internet query enabled

## Clean Up

```bash
terraform destroy
```
