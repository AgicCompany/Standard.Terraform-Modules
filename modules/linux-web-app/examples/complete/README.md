# Example: Complete Usage

Demonstrates all features of the linux-web-app module including Docker application stack, private endpoint, VNet integration, managed identities, application settings, and connection strings.

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

- Resource group `rg-webapp-complete-dev-weu-001`
- Virtual network with private endpoint and VNet integration subnets
- Private DNS zone `privatelink.azurewebsites.net` linked to the VNet
- App Service Plan `asp-webapp-complete-dev-weu-001` (Linux, P1v3 SKU)
- User-assigned managed identity
- Linux Web App `app-complete-dev-weu-001` with:
  - Docker application stack (nginx)
  - Private endpoint with DNS integration
  - VNet integration for outbound traffic
  - System-assigned and user-assigned managed identities
  - Application settings and connection strings
  - Health check path (`/health`)
  - Always-on enabled
  - HTTPS only, TLS 1.2 minimum, FTPS disabled

## Clean Up

```bash
terraform destroy
```
