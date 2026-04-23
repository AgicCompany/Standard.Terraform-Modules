# Example: Basic Usage

Demonstrates basic Container Apps Environment creation with VNet integration and internal load balancer.

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

- Resource group `rg-cae-example-dev-weu-001`
- Log Analytics workspace `law-cae-example-dev-weu-001`
- Virtual network with a `/23` subnet delegated to `Microsoft.App/environments`
- Container Apps Environment `cae-example-dev-weu-001` with:
  - Internal load balancer enabled (default)
  - Log Analytics workspace integration
  - VNet integration

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
| <a name="module_container_app_environment"></a> [container\_app\_environment](#module\_container\_app\_environment) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.cae](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cae_default_domain"></a> [cae\_default\_domain](#output\_cae\_default\_domain) | n/a |
| <a name="output_cae_id"></a> [cae\_id](#output\_cae\_id) | n/a |
| <a name="output_cae_static_ip"></a> [cae\_static\_ip](#output\_cae\_static\_ip) | n/a |
<!-- END_TF_DOCS -->