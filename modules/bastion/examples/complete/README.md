# Example: Complete Usage

Deploys an Azure Bastion host with Standard SKU and all features enabled.

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

- Resource group `rg-bas-complete-dev-weu-001`
- Virtual network `vnet-bas-complete-dev-weu-001` with address space `10.0.0.0/16`
- Subnet `AzureBastionSubnet` with address prefix `10.0.1.0/26`
- Azure Bastion host `bas-complete-dev-weu-001` with Standard SKU
- Public IP `pip-bas-complete-dev-weu-001`
- Standard SKU features: tunneling, IP connect, file copy, 4 scale units

## Clean Up

```bash
terraform destroy
```
