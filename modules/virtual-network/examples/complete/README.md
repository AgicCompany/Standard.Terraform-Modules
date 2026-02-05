# Example: Complete Usage

Demonstrates all features of the virtual-network module including NSG associations, route table associations, service endpoints, and subnet delegations.

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

- Resource group `rg-vnet-complete-dev-weu-001`
- Virtual network `vnet-complete-dev-weu-001` with address space `10.0.0.0/16`
- Network security groups for app and data subnets
- Route table for data subnet
- Five subnets demonstrating different configurations:
  - `snet-app` - Application subnet with NSG and service endpoints
  - `snet-data` - Data subnet with NSG and route table association
  - `snet-private-endpoints` - Dedicated subnet for private endpoints
  - `snet-appservice` - Delegated subnet for App Service
  - `snet-container-apps` - Delegated subnet for Container Apps

## Clean Up

```bash
terraform destroy
```
