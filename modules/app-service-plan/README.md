# app-service-plan

**Complexity:** Low

Creates an Azure App Service Plan with configurable OS type, SKU, worker count, and optional zone redundancy.

## Usage

```hcl
module "app_plan" {
  source = "git::https://github.com/AgicCompany/Standard.Terraform-Modules.git//modules/app-service-plan?ref=app-service-plan/v1.0.0"

  resource_group_name = "rg-app-dev-weu-001"
  location            = "westeurope"
  name                = "asp-payments-dev-weu-001"
  sku_name            = "P1v3"

  tags = local.common_tags
}
```

## Features

- App Service Plan (`azurerm_service_plan`) with configurable OS type (Linux, Windows, WindowsContainer)
- Configurable SKU (Basic, Standard, Premium, Consumption, Elastic Premium)
- Configurable worker count (instance scaling)
- Zone redundancy support via feature flag
- Per-app scaling support via feature flag

## Security Defaults

Service plans are compute-only resources and do not expose network endpoints. Security is managed at the app level.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_service_plan_id` | App Service Plan resource ID (for cross-project consumption) |

## Examples

- [basic](./examples/basic)
- [complete](./examples/complete)

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

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_per_site_scaling"></a> [enable\_per\_site\_scaling](#input\_enable\_per\_site\_scaling) | Enable per-app scaling instead of scaling all apps together | `bool` | `false` | no |
| <a name="input_enable_zone_redundancy"></a> [enable\_zone\_redundancy](#input\_enable\_zone\_redundancy) | Enable zone redundant deployment | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | App Service Plan name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | OS type for the App Service Plan | `string` | `"Linux"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU for the plan (e.g., B1, S1, P1v3, Y1) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | Number of workers (instances) allocated to this plan | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | App Service Plan resource ID |
| <a name="output_kind"></a> [kind](#output\_kind) | The kind value of the service plan |
| <a name="output_name"></a> [name](#output\_name) | App Service Plan name |
| <a name="output_public_service_plan_id"></a> [public\_service\_plan\_id](#output\_public\_service\_plan\_id) | App Service Plan resource ID (for cross-project consumption) |
| <a name="output_reserved"></a> [reserved](#output\_reserved) | Whether this is a Linux plan |
<!-- END_TF_DOCS -->

## Notes

- **AzureRM 4.x:** Use `azurerm_service_plan`, not the removed `azurerm_app_service_plan`.
- **SKU values:** `B1`-`B3`, `S1`-`S3`, `P1v2`-`P3v2`, `P1v3`-`P3v3`, `Y1`, `EP1`-`EP3`.
- **Zone redundancy** requires Premium SKU and `worker_count >= 3`.
- **Consumption plans (`Y1`)** are for serverless Functions.
- **CAF prefix:** `asp`.
