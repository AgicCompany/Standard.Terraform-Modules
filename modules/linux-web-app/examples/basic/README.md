# Example: Basic Usage

Demonstrates basic Linux Web App creation with a .NET application stack and no private endpoint.

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

- Resource group `rg-webapp-example-dev-weu-001`
- App Service Plan `asp-webapp-example-dev-weu-001` (Linux, B1 SKU)
- Linux Web App `app-example-dev-weu-001` with:
  - .NET 8.0 application stack
  - HTTPS only enabled
  - TLS 1.2 minimum
  - FTPS disabled
  - Private endpoint disabled (for simplicity)
  - Always-on enabled

## Clean Up

```bash
terraform destroy
```
