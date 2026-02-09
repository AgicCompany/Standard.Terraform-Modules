# Example: Complete Usage

Demonstrates all features of the service-bus module including Premium SKU, private endpoint, queues, topics, and subscriptions.

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

- Resource group `rg-servicebus-complete-dev-weu-001`
- Virtual network with private endpoint subnet
- Private DNS zone `privatelink.servicebus.windows.net` linked to the VNet
- Service Bus namespace `sb-complete-dev-weu-001` with:
  - Premium SKU with 1 messaging unit
  - Local auth disabled
  - Private endpoint with DNS integration
  - Two queues: `orders` and `notifications`
  - Two topics: `events` (with 2 subscriptions) and `commands` (with 1 subscription)

## Clean Up

```bash
terraform destroy
```
