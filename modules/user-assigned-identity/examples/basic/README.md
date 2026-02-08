# Example: Basic Usage

Demonstrates basic user-assigned managed identity creation.

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

- Resource group `rg-identity-example-dev-weu-001`
- User-assigned managed identity `id-example-dev-weu-001`

## Clean Up

```bash
terraform destroy
```
