# Example: Complete Usage

Demonstrates all features of the mssql-server module including private endpoint, Azure AD authentication, and custom connection policy.

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

- Resource group `rg-sql-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone `privatelink.database.windows.net` linked to the VNet
- SQL Server `sql-complete-dev-weu-001` with:
  - Azure AD-only authentication
  - Current user set as Azure AD administrator
  - Private endpoint with DNS integration
  - Redirect connection policy
  - TLS 1.2 minimum
  - System-assigned managed identity

## Clean Up

```bash
terraform destroy
```
