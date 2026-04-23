# Example: Basic Usage

Demonstrates basic Service Bus namespace with a single queue and no private endpoint.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Azure subscription
- Azure CLI authenticated

## What This Creates

- Resource group `rg-servicebus-example-dev-weu-001`
- Service Bus namespace `sb-example-dev-weu-001` with:
  - Standard SKU
  - Local auth enabled (for simplicity)
  - One queue: `orders`
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
| <a name="module_service_bus"></a> [service\_bus](#module\_service\_bus) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace_endpoint"></a> [namespace\_endpoint](#output\_namespace\_endpoint) | n/a |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | n/a |
<!-- END_TF_DOCS -->