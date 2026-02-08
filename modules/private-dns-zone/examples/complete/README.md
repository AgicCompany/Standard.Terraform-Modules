# Example: Complete Usage

Demonstrates multiple private DNS zones with hub-spoke virtual network linking topology.

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

- Resource group `rg-dns-complete-dev-weu-001`
- Hub virtual network `vnet-hub-dev-weu-001`
- Spoke virtual network `vnet-spoke-dev-weu-001`

**Private DNS Zones:**
- `privatelink.blob.core.windows.net` linked to both hub and spoke VNets
- `privatelink.vaultcore.azure.net` linked to both hub and spoke VNets

## Clean Up

```bash
terraform destroy
```
