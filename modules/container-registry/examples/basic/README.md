# Example: Basic Usage

Demonstrates basic Container Registry creation without a private endpoint.

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

- Resource group `rg-acr-example-dev-weu-001`
- Container Registry `crpaymentsdevweu001` with:
  - Premium SKU
  - Admin account disabled
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
| <a name="module_container_registry"></a> [container\_registry](#module\_container\_registry) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_login_server"></a> [login\_server](#output\_login\_server) | n/a |
| <a name="output_registry_id"></a> [registry\_id](#output\_registry\_id) | n/a |
<!-- END_TF_DOCS -->