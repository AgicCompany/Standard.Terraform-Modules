# Example: Basic Usage

Demonstrates basic Front Door creation with one endpoint, one origin group, one origin, and one route.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated

## What This Creates

- Resource group `rg-frontdoor-example-dev-weu-001`
- Front Door profile `afd-example-dev-001` with:
  - Standard SKU
  - One endpoint: `web`
  - One origin group: `web-origins`
  - One origin: `web-app` pointing to an App Service
  - One route: `web-route` matching all paths

## Clean Up

```bash
terraform destroy
```
