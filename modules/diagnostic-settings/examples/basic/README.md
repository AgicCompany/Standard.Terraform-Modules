# Example: Basic Usage

Demonstrates diagnostic settings sending all logs and metrics from a Key Vault to a Log Analytics workspace.

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

- Resource group `rg-diag-example-dev-weu-001`
- Log Analytics workspace `log-diag-example-dev-weu-001`
- Key Vault `kv-diagex-dev-weu-001` (target resource)
- Diagnostic setting sending all logs and metrics to Log Analytics

## Clean Up

```bash
terraform destroy
```
