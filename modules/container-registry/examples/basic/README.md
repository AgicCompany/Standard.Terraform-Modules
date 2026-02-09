# Example: Basic Usage

Demonstrates basic Container Registry creation without a private endpoint.

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

- Resource group `rg-acr-example-dev-weu-001`
- Container Registry `crpaymentsdevweu001` with:
  - Premium SKU
  - Admin account disabled
  - Public network access disabled (default)
  - System-assigned managed identity
  - No private endpoint (disabled for simplicity)

## Clean Up

```bash
terraform destroy
```
