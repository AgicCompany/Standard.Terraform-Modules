# Example: Basic Usage

This example demonstrates a minimal SQL Database on an existing SQL server with default settings.

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

- An Azure SQL Server with AAD-only authentication
- An Azure SQL Database with S0 SKU (default)

## Clean Up

```bash
terraform destroy
```
