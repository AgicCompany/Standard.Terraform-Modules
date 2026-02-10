# Example: Basic Usage

Demonstrates basic Linux VM creation with SSH key authentication.

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

- Resource group `rg-vm-example-dev-weu-001`
- Virtual network with compute subnet
- SSH key pair (generated for convenience)
- Linux VM `vm-example-dev-weu-001` with:
  - Standard_B1s size
  - Ubuntu 22.04 LTS Gen2
  - SSH key authentication (password disabled)
  - No public IP
  - Premium OS disk

## Clean Up

```bash
terraform destroy
```
