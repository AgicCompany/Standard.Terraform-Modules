# Example: Complete Usage

This example demonstrates a SQL Database with all features enabled, suitable for production workloads.

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

- An Azure SQL Server with AAD-only authentication and TLS 1.2
- An Azure SQL Database with P1 SKU
- 50 GB maximum size
- 35-day point-in-time restore retention
- Zone redundancy enabled
- Geo-redundant backup enabled
- Read scale-out enabled

## Clean Up

```bash
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_database"></a> [database](#module\_database) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_mssql_server.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_id"></a> [database\_id](#output\_database\_id) | n/a |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | n/a |
<!-- END_TF_DOCS -->