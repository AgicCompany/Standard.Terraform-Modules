# Example: Basic Usage

Demonstrates basic Key Vault creation with a private endpoint (the default configuration).

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

- Resource group `rg-kv-example-dev-weu-001`
- Virtual network `vnet-example-dev-weu-001` with private endpoint subnet
- Private DNS zone `privatelink.vaultcore.azure.net` linked to the VNet
- Key Vault `kv-example-dev-weu-001` with:
  - RBAC authorization enabled
  - Soft delete (90 days retention)
  - Purge protection enabled
  - Private endpoint

## Clean Up

```bash
terraform destroy
```

**Note:** Due to purge protection, the Key Vault will remain in a soft-deleted state for 90 days after destruction. To immediately purge it (if needed), use the Azure CLI:

```bash
az keyvault purge --name kv-example-dev-weu-001 --location westeurope
```
