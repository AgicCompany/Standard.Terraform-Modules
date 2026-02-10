# Example: Complete Usage

Deploys an Event Hub namespace with multiple event hubs, consumer groups, and private endpoint.

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

- Resource group `rg-evh-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone `privatelink.servicebus.windows.net` linked to the VNet
- Event Hub namespace `evh-complete-dev-weu-001` with:
  - Standard SKU with auto-inflate (up to 10 throughput units)
  - Private endpoint with DNS integration
  - Local authentication disabled (default)
  - Public access disabled (default)
  - TLS 1.2 minimum
- Event hub `events` with 4 partitions, 7 day retention, and `analytics` consumer group
- Event hub `telemetry` with 2 partitions and 1 day retention
- Namespace authorization rule `app-sender` with send permission

## Clean Up

```bash
terraform destroy
```
