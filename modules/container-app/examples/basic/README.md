# Example: Basic Usage

Demonstrates basic Container App creation with a hello-world image and external ingress.

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

- Resource group `rg-ca-example-dev-weu-001`
- Log Analytics workspace `law-ca-example-dev-weu-001`
- Container Apps Environment `cae-example-dev-weu-001` (Consumption, external)
- Container App `ca-helloworld-dev-weu-001` with:
  - Hello-world container image
  - 0.25 CPU / 0.5Gi memory
  - HTTP ingress on port 80 (external)

## Clean Up

```bash
terraform destroy
```
