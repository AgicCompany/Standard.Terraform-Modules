# Example: Complete Usage

Demonstrates all features of the front-door module including multiple endpoints, origin groups with health probes, weighted origins, and routes.

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

- Resource group `rg-frontdoor-complete-dev-weu-001`
- Front Door profile `afd-complete-dev-001` with:
  - Standard SKU with 120s response timeout
  - Two endpoints: `web` and `api`
  - Two origin groups with health probes: `web-origins` and `api-origins`
  - Three origins: `web-primary` (priority 1), `web-secondary` (priority 2), `api-app`
  - Two routes: `web-route` (all paths) and `api-route` (/api/* paths)

## Clean Up

```bash
terraform destroy
```
