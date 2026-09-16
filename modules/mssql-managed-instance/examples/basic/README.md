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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sql_managed_instance"></a> [sql\_managed\_instance](#module\_sql\_managed\_instance) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route_table.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.sqlmi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_instance_fqdn"></a> [managed\_instance\_fqdn](#output\_managed\_instance\_fqdn) | n/a |
| <a name="output_managed_instance_id"></a> [managed\_instance\_id](#output\_managed\_instance\_id) | n/a |
<!-- END_TF_DOCS -->
