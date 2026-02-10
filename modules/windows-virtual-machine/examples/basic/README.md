# Example: Basic Usage

Demonstrates basic Windows VM creation with password authentication.

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

- Resource group `rg-winvm-example-dev-weu-001`
- Virtual network with compute subnet
- Random password (generated for convenience)
- Windows VM `vm-winex-dev-001` with:
  - Standard_B2s size
  - Windows Server 2022 Datacenter Gen2
  - Password authentication
  - No public IP
  - Premium OS disk

## Clean Up

```bash
terraform destroy
```
