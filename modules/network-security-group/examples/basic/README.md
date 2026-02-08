# Example: Basic Usage

Demonstrates basic network security group creation with no custom rules (Azure default rules only).

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

- Resource group `rg-nsg-example-dev-weu-001`
- Network security group `nsg-example-dev-weu-001` with Azure default rules only

## Clean Up

```bash
terraform destroy
```
