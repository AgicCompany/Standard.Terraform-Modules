# container-app-environment

**Complexity:** Medium

Creates an Azure Container Apps Environment with secure defaults and VNet integration.

## Usage

```hcl
module "cae" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//container-app-environment?ref=container-app-environment/v1.0.0"

  resource_group_name = "rg-cae-dev-weu-001"
  location            = "westeurope"
  name                = "cae-payments-dev-weu-001"

  log_analytics_workspace_id = module.law.id
  infrastructure_subnet_id   = module.vnet.subnet_ids["cae-subnet"]

  tags = local.common_tags
}
```

## Features

- Log Analytics workspace integration (required)
- VNet integration with internal load balancer
- Workload profile configuration (Consumption and Dedicated)
- Zone redundancy support

## Security Defaults

This module applies secure defaults:

| Setting | Default | Override Variable |
|---------|---------|-------------------|
| Internal load balancer | Enabled | `enable_internal_load_balancer` |

## VNet Integration

When `enable_internal_load_balancer = true` (default), a `infrastructure_subnet_id` is required. The subnet must be:

- Dedicated to the Container Apps Environment (no other resources)
- Minimum `/23` CIDR range (`/21` recommended for production)
- Delegated to `Microsoft.App/environments`

The environment gets a private IP and apps are not publicly accessible unless explicitly configured with external ingress.

## Public Outputs

These outputs are designed for cross-project state consumption:

| Output | Description |
|--------|-------------|
| `public_container_app_environment_id` | Container Apps Environment resource ID |
| `public_container_app_environment_default_domain` | Default domain of the environment |

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_environment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_internal_load_balancer"></a> [enable\_internal\_load\_balancer](#input\_enable\_internal\_load\_balancer) | Use internal load balancer. Requires VNet integration. | `bool` | `true` | no |
| <a name="input_enable_zone_redundancy"></a> [enable\_zone\_redundancy](#input\_enable\_zone\_redundancy) | Enable zone redundant deployment. Requires VNet integration. | `bool` | `false` | no |
| <a name="input_infrastructure_subnet_id"></a> [infrastructure\_subnet\_id](#input\_infrastructure\_subnet\_id) | Subnet ID for VNet integration. Required when enable\_internal\_load\_balancer = true. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID for environment logging | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Container Apps Environment name (full CAF-compliant name, provided by consumer) | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_workload_profiles"></a> [workload\_profiles](#input\_workload\_profiles) | Dedicated workload profiles. Key is used as profile name. Empty map = Consumption only. | <pre>map(object({<br/>    workload_profile_type = string<br/>    minimum_count         = number<br/>    maximum_count         = number<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_domain"></a> [default\_domain](#output\_default\_domain) | Default domain of the environment |
| <a name="output_docker_bridge_cidr"></a> [docker\_bridge\_cidr](#output\_docker\_bridge\_cidr) | Docker bridge CIDR |
| <a name="output_id"></a> [id](#output\_id) | Container Apps Environment resource ID |
| <a name="output_name"></a> [name](#output\_name) | Container Apps Environment name |
| <a name="output_platform_reserved_cidr"></a> [platform\_reserved\_cidr](#output\_platform\_reserved\_cidr) | Platform reserved CIDR |
| <a name="output_platform_reserved_dns_ip_address"></a> [platform\_reserved\_dns\_ip\_address](#output\_platform\_reserved\_dns\_ip\_address) | Platform reserved DNS IP address |
| <a name="output_public_container_app_environment_default_domain"></a> [public\_container\_app\_environment\_default\_domain](#output\_public\_container\_app\_environment\_default\_domain) | Default domain of the environment (for cross-project consumption) |
| <a name="output_public_container_app_environment_id"></a> [public\_container\_app\_environment\_id](#output\_public\_container\_app\_environment\_id) | Container Apps Environment resource ID (for cross-project consumption) |
| <a name="output_static_ip_address"></a> [static\_ip\_address](#output\_static\_ip\_address) | Static IP address of the environment |
<!-- END_TF_DOCS -->

## Notes

- **Subnet requirements:** The subnet used for VNet integration must be dedicated to the Container Apps Environment (no other resources). It needs a minimum `/23` CIDR range (`/21` recommended for production). The subnet must be delegated to `Microsoft.App/environments`.
- **Internal vs external:** When `enable_internal_load_balancer = true`, the environment's default domain resolves to a private IP. Individual container apps can still expose external ingress if needed, but the environment itself is private. When `false`, the environment gets a public IP.
- **Log Analytics requirement:** Azure requires a Log Analytics workspace for Container Apps Environments. This is not optional -- the `log_analytics_workspace_id` is always required.
- **Workload profiles:** An empty `workload_profiles` map means Consumption-only plan. Adding workload profiles enables dedicated compute with guaranteed resources. The `Consumption` profile is always available even when dedicated profiles exist.
- **Zone redundancy:** Requires a VNet-integrated environment. Cannot be changed after creation -- this is a create-time setting.
- **Naming:** CAF prefix for Container Apps Environments is `cae`. Example: `cae-payments-dev-weu-001`.
- **One environment, many apps:** Similar to an App Service Plan, one environment hosts multiple container apps. The environment defines the networking and logging; the apps define the workloads.
