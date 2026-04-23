# Example: Basic Usage

Demonstrates basic Redis Cache creation without a private endpoint.

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

- Resource group `rg-redis-example-dev-weu-001`
- Redis Cache `redis-example-dev-weu-001` with:
  - Basic C0 SKU
  - TLS 1.2 minimum
  - Non-SSL port disabled
  - Public access enabled (for simplicity)
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
| <a name="module_redis_cache"></a> [redis\_cache](#module\_redis\_cache) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redis_hostname"></a> [redis\_hostname](#output\_redis\_hostname) | n/a |
| <a name="output_redis_id"></a> [redis\_id](#output\_redis\_id) | n/a |
| <a name="output_redis_ssl_port"></a> [redis\_ssl\_port](#output\_redis\_ssl\_port) | n/a |
<!-- END_TF_DOCS -->