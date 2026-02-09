# Example: Complete Usage

Demonstrates all features of the container-registry module including private endpoint and geo-replication.

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

- Resource group `rg-acr-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone `privatelink.azurecr.io` linked to the VNet
- Container Registry `crcompletdevweu001` with:
  - Premium SKU
  - Admin account disabled
  - Private endpoint with DNS integration
  - Geo-replication to North Europe
  - System-assigned managed identity

## Clean Up

```bash
terraform destroy
```
