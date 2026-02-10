# Example: Basic Usage

Deploys an API Management service with Developer SKU.

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

- Resource group `rg-apim-example-dev-weu-001`
- API Management service `apim-example-dev-weu-001` with:
  - Developer SKU (capacity 1)
  - Public access enabled (for simplicity)
  - Private endpoint disabled (for simplicity)
  - SystemAssigned managed identity

## Clean Up

```bash
terraform destroy
```
