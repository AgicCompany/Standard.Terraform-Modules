# Example: Basic Usage

Demonstrates basic Linux Web App creation with a .NET application stack and no private endpoint.

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

- Resource group `rg-webapp-example-dev-weu-001`
- App Service Plan `asp-webapp-example-dev-weu-001` (Linux, B1 SKU)
- Linux Web App `app-example-dev-weu-001` with:
  - .NET 8.0 application stack
  - HTTPS only enabled
  - TLS 1.2 minimum
  - FTPS disabled
  - Private endpoint disabled (for simplicity)
  - Always-on enabled

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
| <a name="module_web_app"></a> [web\_app](#module\_web\_app) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_web_app_hostname"></a> [web\_app\_hostname](#output\_web\_app\_hostname) | n/a |
| <a name="output_web_app_id"></a> [web\_app\_id](#output\_web\_app\_id) | n/a |
<!-- END_TF_DOCS -->