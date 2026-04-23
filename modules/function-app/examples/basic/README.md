# Example: Basic Usage

Demonstrates basic Linux Function App creation with a Python application stack on a Consumption plan, without private endpoint or Application Insights.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated (`az login`)

## What This Creates

- Resource group `rg-func-example-dev-weu-001`
- Storage account `stfuncexampledevweu001` (required by Functions runtime)
- App Service Plan `asp-func-example-dev-weu-001` (Linux, Y1 Consumption SKU)
- Linux Function App `func-example-dev-weu-001` with:
  - Python 3.11 application stack
  - HTTPS only enabled
  - TLS 1.2 minimum
  - FTPS disabled
  - Private endpoint disabled (for simplicity)
  - Application Insights disabled

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
| <a name="module_function_app"></a> [function\_app](#module\_function\_app) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_app_hostname"></a> [function\_app\_hostname](#output\_function\_app\_hostname) | n/a |
| <a name="output_function_app_id"></a> [function\_app\_id](#output\_function\_app\_id) | n/a |
<!-- END_TF_DOCS -->