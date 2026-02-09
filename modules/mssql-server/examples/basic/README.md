# Example: Basic Usage

Demonstrates basic SQL Server creation with Azure AD-only authentication and no private endpoint.

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

- Resource group `rg-sql-example-dev-weu-001`
- SQL Server `sql-payments-dev-weu-001` with:
  - Azure AD-only authentication (no SQL credentials needed)
  - Current user set as Azure AD administrator
  - TLS 1.2 minimum
  - Public network access disabled (default)
  - System-assigned managed identity
  - No private endpoint (disabled for simplicity)

## Clean Up

```bash
terraform destroy
```
