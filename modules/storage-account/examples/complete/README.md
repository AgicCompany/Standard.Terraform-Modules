# Example: Complete Usage

Demonstrates all features of the storage-account module including all four private endpoints, versioning, soft delete, and public access with network rules.

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

- Resource group `rg-st-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zones for blob, file, table, and queue

**Storage account with all private endpoints (`stcompletedevweu001`):**
- Standard tier, ZRS replication
- TLS 1.2 minimum, HTTPS only
- Blob versioning enabled
- Blob and container soft delete (30 days)
- Private endpoints for blob, file, table, and queue

**Storage account with public access (`stpublicdevweu001`):**
- Standard tier, LRS replication
- Public network access enabled
- Network rules with IP restrictions

## Clean Up

```bash
terraform destroy
```
