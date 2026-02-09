# Example: Complete Usage

Demonstrates all features of the container-app module including probes, init containers, scale rules, secrets, and managed identity.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated
- Existing resource group (or modify example to create one)

## What This Creates

- Resource group `rg-ca-complete-dev-weu-001`
- Log Analytics workspace `law-ca-complete-dev-weu-001`
- Virtual network with a `/21` subnet delegated to `Microsoft.App/environments`
- Container Apps Environment `cae-complete-dev-weu-001` with:
  - Internal load balancer
  - Dedicated workload profile (D4)
- Container App `ca-api-complete-dev-weu-001` with:
  - Hello-world container image (0.5 CPU / 1Gi memory)
  - HTTP ingress on port 80 (external)
  - Liveness, readiness, and startup probes
  - Init container for database migrations
  - Secret-referenced environment variable
  - HTTP scale rule (1-5 replicas, 50 concurrent requests)
  - System-assigned managed identity
  - Dedicated workload profile

## Clean Up

```bash
terraform destroy
```
