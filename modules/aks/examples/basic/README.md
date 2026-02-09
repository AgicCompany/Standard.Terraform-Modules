# Example: Basic Usage

Deploys an AKS cluster with default settings: private cluster, Azure CNI Overlay, autoscaling, Azure AD RBAC, and Container Insights.

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

- Log Analytics workspace (for Container Insights)
- AKS cluster with default system node pool

## Clean Up

```bash
terraform destroy
```
