# Example: Complete Usage

Demonstrates all features of the front-door module including multiple endpoints, origin groups with health probes, weighted origins, and routes.

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

- Resource group `rg-frontdoor-complete-dev-weu-001`
- Front Door profile `afd-complete-dev-001` with:
  - Standard SKU with 120s response timeout
  - Two endpoints: `web` and `api`
  - Two origin groups with health probes: `web-origins` and `api-origins`
  - Three origins: `web-primary` (priority 1), `web-secondary` (priority 2), `api-app`
  - Two routes: `web-route` (all paths) and `api-route` (/api/* paths)

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
| <a name="output_custom_domain_ids"></a> [custom\_domain\_ids](#output\_custom\_domain\_ids) | n/a |
| <a name="output_custom_domain_validation_tokens"></a> [custom\_domain\_validation\_tokens](#output\_custom\_domain\_validation\_tokens) | n/a |
| <a name="output_endpoint_host_names"></a> [endpoint\_host\_names](#output\_endpoint\_host\_names) | n/a |
| <a name="output_firewall_policy_id"></a> [firewall\_policy\_id](#output\_firewall\_policy\_id) | n/a |
| <a name="output_frontdoor_id"></a> [frontdoor\_id](#output\_frontdoor\_id) | n/a |
| <a name="output_origin_group_ids"></a> [origin\_group\_ids](#output\_origin\_group\_ids) | n/a |
| <a name="output_route_ids"></a> [route\_ids](#output\_route\_ids) | n/a |
| <a name="output_rule_set_ids"></a> [rule\_set\_ids](#output\_rule\_set\_ids) | n/a |
<!-- END_TF_DOCS -->