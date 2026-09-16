# Example: Basic Usage

Demonstrates a minimal SQL Managed Instance with Microsoft Entra-only authentication, service-managed TDE, and Advanced Threat Protection defaults. The delegated subnet, NSG and route table it requires are created inline.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

> **Provisioning time:** creating a SQL Managed Instance takes several hours (up to 24 h; the first instance in a subnet is the slowest). Terraform blocks for the whole duration.

## Prerequisites

- Azure subscription
- Azure CLI authenticated (the signed-in user becomes the Entra administrator)

## What This Creates

- Resource group `rg-sqlmi-example-dev-weu-001`
- Virtual network `10.10.0.0/16` with subnet `snet-sqlmi` (`10.10.0.0/26`) delegated to `Microsoft.Sql/managedInstances`
- Network security group and route table associated to the subnet (Azure injects its required rules)
- SQL Managed Instance `sqlmi-payments-dev-weu-001` with:
  - `GP_Gen5`, 4 vCores, 32 GB, license included
  - Entra-only authentication (no SQL credentials)
  - System-assigned managed identity
  - TLS 1.2 minimum, public data endpoint disabled
  - Transparent data encryption with a service-managed key
  - Advanced Threat Protection enabled

## Clean Up

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
