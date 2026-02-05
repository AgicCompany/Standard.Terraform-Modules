# Example: Basic Usage

Demonstrates basic storage account creation with a blob private endpoint (the default configuration).

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

- Resource group `rg-st-example-dev-weu-001`
- Virtual network `vnet-example-dev-weu-001` with private endpoint subnet
- Private DNS zone `privatelink.blob.core.windows.net` linked to the VNet
- Storage account `stexampledevweu001` with:
  - Standard tier, LRS replication
  - TLS 1.2 minimum, HTTPS only
  - Blob and container soft delete (7 days)
  - Public network access disabled
  - Blob private endpoint

## Clean Up

```bash
terraform destroy
```
