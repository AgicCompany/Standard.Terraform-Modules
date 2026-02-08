# Example: Complete Usage

Demonstrates user-assigned managed identity creation with RBAC role assignments.

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

- Resource group `rg-identity-complete-dev-weu-001`
- User-assigned managed identity `id-app-dev-weu-001`

**Role Assignments:**
- Reader role on the resource group
- Key Vault Secrets User role on the resource group

## Clean Up

```bash
terraform destroy
```
