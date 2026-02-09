# Example: Complete Usage

Deploys a production-ready AKS cluster with Standard SKU, custom node pool settings, VNet integration, authorized IP ranges, and patch auto-upgrade.

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

- Virtual network with node subnet
- Log Analytics workspace (for Container Insights)
- AKS cluster with:
  - Standard SKU tier (Uptime SLA)
  - Pinned Kubernetes version
  - Custom node resource group name
  - Azure AD admin group
  - Custom VM size and disk configuration
  - Zone-redundant node pool
  - Azure CNI Overlay networking
  - Authorized IP ranges
  - Patch auto-upgrade channel

## Clean Up

```bash
terraform destroy
```
