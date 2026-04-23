# Example: Basic Usage

Demonstrates basic Container App creation with a hello-world image and external ingress.

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

- Resource group `rg-ca-example-dev-weu-001`
- Log Analytics workspace `law-ca-example-dev-weu-001`
- Container Apps Environment `cae-example-dev-weu-001` (Consumption, external)
- Container App `ca-helloworld-dev-weu-001` with:
  - Hello-world container image
  - 0.25 CPU / 0.5Gi memory
  - HTTP ingress on port 80 (external)

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
| <a name="module_container_app"></a> [container\_app](#module\_container\_app) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_environment.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_fqdn"></a> [container\_app\_fqdn](#output\_container\_app\_fqdn) | n/a |
| <a name="output_container_app_id"></a> [container\_app\_id](#output\_container\_app\_id) | n/a |
<!-- END_TF_DOCS -->