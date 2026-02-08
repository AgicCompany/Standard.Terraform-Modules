# Example: Complete Usage

Demonstrates diagnostic settings with selective log categories, dedicated tables, and multiple target resources.

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

- Resource group `rg-diag-complete-dev-weu-001`
- Log Analytics workspace `log-diag-complete-dev-weu-001`
- Key Vault `kv-diagcm-dev-weu-001`
- Storage account `stdiagcmdevweu001`

**Diagnostic Settings:**
- Key Vault: selective categories (AuditEvent, AzurePolicyEvaluationDetails) with dedicated tables
- Storage account: all categories with dedicated tables

## Clean Up

```bash
terraform destroy
```
