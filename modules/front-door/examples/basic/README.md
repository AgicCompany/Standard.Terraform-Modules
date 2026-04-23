# Example: Basic Usage

Demonstrates basic Front Door creation with one endpoint, one origin group, one origin, and one route.

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

- Resource group `rg-frontdoor-example-dev-weu-001`
- Front Door profile `afd-example-dev-001` with:
  - Standard SKU
  - One endpoint: `web`
  - One origin group: `web-origins`
  - One origin: `web-app` pointing to an App Service
  - One route: `web-route` matching all paths

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
| <a name="module_front_door"></a> [front\_door](#module\_front\_door) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_host_names"></a> [endpoint\_host\_names](#output\_endpoint\_host\_names) | n/a |
| <a name="output_frontdoor_id"></a> [frontdoor\_id](#output\_frontdoor\_id) | n/a |
<!-- END_TF_DOCS -->