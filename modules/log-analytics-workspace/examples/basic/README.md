# Example: Basic Usage

Demonstrates basic Log Analytics workspace creation with secure defaults.

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

- Resource group `rg-log-example-dev-weu-001`
- Log Analytics workspace `log-example-dev-weu-001` with:
  - PerGB2018 SKU
  - 30-day retention
  - Internet ingestion disabled
  - Internet query disabled

## Clean Up

```bash
terraform destroy
```
