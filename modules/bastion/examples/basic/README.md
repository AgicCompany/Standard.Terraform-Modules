# Example: Basic Usage

Deploys an Azure Bastion host with Basic SKU.

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

- Resource group `rg-bas-example-dev-weu-001`
- Virtual network `vnet-bas-example-dev-weu-001` with address space `10.0.0.0/16`
- Subnet `AzureBastionSubnet` with address prefix `10.0.1.0/26`
- Azure Bastion host `bas-example-dev-weu-001` with Basic SKU
- Public IP `pip-bas-example-dev-weu-001`

## Clean Up

```bash
terraform destroy
```
