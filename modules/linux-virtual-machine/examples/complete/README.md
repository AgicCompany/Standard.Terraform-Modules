# Example: Complete Usage

Demonstrates all features of the linux-virtual-machine module including identity, boot diagnostics, and data disks.

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

- Resource group `rg-vm-complete-dev-weu-001`
- Virtual network with compute subnet
- SSH key pair (generated for convenience)
- Linux VM `vm-complete-dev-weu-001` with:
  - Standard_B1s size in zone 1
  - Ubuntu 22.04 LTS Gen2
  - SSH key authentication (password disabled)
  - System-assigned managed identity
  - Boot diagnostics (managed storage)
  - One 32GB Premium data disk

## Clean Up

```bash
terraform destroy
```
