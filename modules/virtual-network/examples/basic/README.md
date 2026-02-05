# Example: Basic Usage

Demonstrates basic virtual network creation with two subnets.

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

- Resource group `rg-vnet-example-dev-weu-001`
- Virtual network `vnet-example-dev-weu-001` with address space `10.0.0.0/16`
- Subnet `snet-app` with address prefix `10.0.1.0/24`
- Subnet `snet-data` with address prefix `10.0.2.0/24`

## Clean Up

```bash
terraform destroy
```
