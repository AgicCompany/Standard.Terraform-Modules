# Example: Basic Usage

Deploys an Application Gateway with a single backend, listener, and routing rule.

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

- Resource group `rg-appgw-example-dev-weu-001`
- Virtual network `vnet-appgw-example-dev-weu-001` with address space `10.0.0.0/16`
- Subnet `snet-appgw` with address prefix `10.0.1.0/24`
- Application Gateway `agw-example-dev-weu-001` (Standard_v2)
- Public IP `pip-agw-example-dev-weu-001`

## Clean Up

```bash
terraform destroy
```
