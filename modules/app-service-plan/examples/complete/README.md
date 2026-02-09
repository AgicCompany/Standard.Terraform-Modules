# Example: Complete Usage

This example demonstrates an App Service Plan with all features enabled, suitable for production workloads.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated
- Existing resource group (or modify example to create one)

## What This Creates

- A Linux App Service Plan with a P1v3 (Premium) SKU
- 3 worker instances with zone redundancy
- Per-app scaling enabled

## Clean Up

```bash
terraform destroy
```
