# Example: Basic Usage

Demonstrates a single private DNS zone with one virtual network link for blob storage private endpoints.

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

- Resource group `rg-dns-example-dev-weu-001`
- Virtual network `vnet-example-dev-weu-001`
- Private DNS zone `privatelink.blob.core.windows.net`
- Virtual network link to the VNet

## Clean Up

```bash
terraform destroy
```
