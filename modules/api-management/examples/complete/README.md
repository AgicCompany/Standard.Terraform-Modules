# Example: Complete Usage

Deploys an API Management service with private endpoint, managed identity, and client certificates.

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

- Resource group `rg-apim-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone `privatelink.azure-api.net` linked to the VNet
- API Management service `apim-complete-dev-weu-001` with:
  - Developer SKU (capacity 1)
  - SystemAssigned managed identity
  - Client certificate authentication enabled
  - Private endpoint with DNS integration
  - Public access disabled (default)

## Clean Up

```bash
terraform destroy
```
