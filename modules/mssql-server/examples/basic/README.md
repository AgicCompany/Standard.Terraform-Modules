# Example: Basic Usage

Demonstrates basic SQL Server creation with Azure AD-only authentication and no private endpoint.

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

- Resource group `rg-sql-example-dev-weu-001`
- SQL Server `sql-payments-dev-weu-001` with:
  - Azure AD-only authentication (no SQL credentials needed)
  - Current user set as Azure AD administrator
  - TLS 1.2 minimum
  - Public network access disabled (default)
  - System-assigned managed identity
  - No private endpoint (disabled for simplicity)

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.69.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sql_server"></a> [sql\_server](#module\_sql\_server) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sql_server_fqdn"></a> [sql\_server\_fqdn](#output\_sql\_server\_fqdn) | n/a |
| <a name="output_sql_server_id"></a> [sql\_server\_id](#output\_sql\_server\_id) | n/a |
<!-- END_TF_DOCS -->