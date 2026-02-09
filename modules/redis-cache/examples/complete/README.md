# Example: Complete Usage

Demonstrates all features of the redis-cache module including Premium SKU, private endpoint, zones, and custom configuration.

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

- Resource group `rg-redis-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone `privatelink.redis.cache.windows.net` linked to the VNet
- Redis Cache `redis-complete-dev-weu-001` with:
  - Premium P1 SKU
  - Custom maxmemory policy (allkeys-lru)
  - Patch schedule (Saturday 2:00 UTC)
  - Availability zones (1, 2, 3)
  - Private endpoint with DNS integration

## Clean Up

```bash
terraform destroy
```
