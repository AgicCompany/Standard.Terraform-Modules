# Example: Basic Usage

Demonstrates basic Redis Cache creation without a private endpoint.

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

- Resource group `rg-redis-example-dev-weu-001`
- Redis Cache `redis-example-dev-weu-001` with:
  - Basic C0 SKU
  - TLS 1.2 minimum
  - Non-SSL port disabled
  - Public access enabled (for simplicity)
  - No private endpoint (disabled for simplicity)

## Clean Up

```bash
terraform destroy
```
