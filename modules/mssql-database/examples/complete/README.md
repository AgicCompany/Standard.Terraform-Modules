# Example: Complete Usage

This example demonstrates a SQL Database with all features enabled, suitable for production workloads.

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

- An Azure SQL Server with AAD-only authentication and TLS 1.2
- An Azure SQL Database with P1 SKU
- 50 GB maximum size
- 35-day point-in-time restore retention
- Zone redundancy enabled
- Geo-redundant backup enabled
- Read scale-out enabled

## Clean Up

```bash
terraform destroy
```
