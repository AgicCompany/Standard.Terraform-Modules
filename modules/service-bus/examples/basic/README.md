# Example: Basic Usage

Demonstrates basic Service Bus namespace with a single queue and no private endpoint.

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

- Resource group `rg-servicebus-example-dev-weu-001`
- Service Bus namespace `sb-example-dev-weu-001` with:
  - Standard SKU
  - Local auth enabled (for simplicity)
  - One queue: `orders`
  - No private endpoint (disabled for simplicity)

## Clean Up

```bash
terraform destroy
```
