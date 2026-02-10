# Example: Basic Usage

Deploys an Event Hub namespace with a single event hub using default settings.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated

## What This Creates

- Resource group `rg-evh-example-dev-weu-001`
- Event Hub namespace `evh-example-dev-weu-001` with:
  - Standard SKU
  - Public network access enabled
  - Local authentication enabled
  - No private endpoint (disabled for simplicity)
- Event hub `events` with 2 partitions and 1 day retention

## Clean Up

```bash
terraform destroy
```
