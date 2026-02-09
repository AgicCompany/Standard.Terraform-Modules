# Example: Complete Usage

Demonstrates all features of the function-app module including .NET application stack, private endpoint, VNet integration, system-assigned managed identity, Application Insights, and custom application settings.

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

- Resource group `rg-func-complete-dev-weu-001`
- Virtual network with private endpoint and VNet integration subnets
- Private DNS zone `privatelink.azurewebsites.net` linked to the VNet
- Storage account `stfunccompletedevweu001` (required by Functions runtime)
- App Service Plan `asp-func-complete-dev-weu-001` (Linux, P1v3 SKU)
- Log Analytics workspace and Application Insights
- Linux Function App `func-complete-dev-weu-001` with:
  - .NET 8.0 isolated runtime application stack
  - Private endpoint with DNS integration
  - VNet integration for outbound traffic
  - System-assigned managed identity
  - Application Insights integration
  - Custom application settings
  - HTTPS only, TLS 1.2 minimum, FTPS disabled

## Clean Up

```bash
terraform destroy
```
