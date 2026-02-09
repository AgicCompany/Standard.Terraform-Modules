# Example: Basic Usage

Demonstrates basic Linux Function App creation with a Python application stack on a Consumption plan, without private endpoint or Application Insights.

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

- Resource group `rg-func-example-dev-weu-001`
- Storage account `stfuncexampledevweu001` (required by Functions runtime)
- App Service Plan `asp-func-example-dev-weu-001` (Linux, Y1 Consumption SKU)
- Linux Function App `func-example-dev-weu-001` with:
  - Python 3.11 application stack
  - HTTPS only enabled
  - TLS 1.2 minimum
  - FTPS disabled
  - Private endpoint disabled (for simplicity)
  - Application Insights disabled

## Clean Up

```bash
terraform destroy
```
