# Example: Complete Usage

Demonstrates all features of the windows-virtual-machine module including identity, boot diagnostics, hybrid benefit, and data disks.

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

- Resource group `rg-winvm-complete-dev-weu-001`
- Virtual network with compute subnet
- Random password (generated for convenience)
- Windows VM `vm-wincm-dev-001` with:
  - Standard_B2s size in zone 1
  - Windows Server 2022 Datacenter Gen2
  - Password authentication
  - Azure Hybrid Benefit enabled
  - W. Europe Standard Time timezone
  - System-assigned managed identity
  - Boot diagnostics (managed storage)
  - One 64GB Premium data disk

## Clean Up

```bash
terraform destroy
```
